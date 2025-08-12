class Admin::ContactListMembershipsController < Admin::BaseController
  def create
    @list = current_user.lists.find(params[:list_id])
    @contact = Contact.find(params[:contact_id])
    
    @membership = @list.contact_list_memberships.build(contact: @contact)
    
    if @membership.save
      render json: { 
        success: true, 
        message: "Contact added to #{@list.name}",
        contacts_count: @list.reload.contacts_count
      }
    else
      render json: { 
        success: false, 
        message: @membership.errors.full_messages.join(', ')
      }
    end
  end

  def destroy
    # Handle different ID formats: either direct membership ID or list_id_contact_id format
    if params[:id].include?('_')
      list_id, contact_id = params[:id].split('_')
      @list = current_user.lists.find(list_id)
      @contact = Contact.find(contact_id)
      @membership = @list.contact_list_memberships.find_by(contact: @contact)
    else
      @membership = ContactListMembership.find(params[:id])
      @list = @membership.list
      @contact = @membership.contact
      # Ensure user owns the list
      unless current_user.lists.include?(@list)
        respond_to do |format|
          format.html { redirect_to admin_lists_path, alert: 'Unauthorized' }
          format.json { render json: { success: false, message: 'Unauthorized' } }
        end
        return
      end
    end
    
    unless @membership
      respond_to do |format|
        format.html { redirect_to admin_lists_path, alert: 'Membership not found' }
        format.json { render json: { success: false, message: 'Membership not found' } }
      end
      return
    end
    
    contact_name = @contact.full_name.presence || @contact.company_name
    
    if @membership.destroy
      message = "#{contact_name} removed from #{@list.name}"
      respond_to do |format|
        format.html { redirect_to admin_list_path(@list), notice: message }
        format.json { 
          render json: { 
            success: true, 
            message: message,
            contacts_count: @list.reload.contacts_count,
            membership_id: params[:id],
            contact_id: @contact.id
          }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_list_path(@list), alert: 'Failed to remove contact' }
        format.json { render json: { success: false, message: 'Failed to remove contact' } }
      end
    end
  end

  def bulk_add
    @list = current_user.lists.find(params[:list_id]) if params[:list_id].present?
    contact_ids = params[:contact_ids] || []
    
    if @list && contact_ids.any?
      added_count = 0
      skipped_count = 0
      
      contact_ids.each do |contact_id|
        contact = Contact.find_by(id: contact_id)
        next unless contact
        
        membership = @list.contact_list_memberships.build(contact: contact)
        if membership.save
          added_count += 1
        else
          skipped_count += 1
        end
      end
      
      message = "Added #{added_count} contacts to #{@list.name}"
      message += ", #{skipped_count} skipped (already in list)" if skipped_count > 0
      
      render json: { 
        success: true, 
        message: message,
        added_count: added_count,
        skipped_count: skipped_count,
        contacts_count: @list.reload.contacts_count,
        redirect_url: admin_list_path(@list)
      }
    else
      render json: { 
        success: false, 
        message: 'Invalid list or no contacts selected'
      }
    end
  end

  def bulk_update
    @list = current_user.lists.find(params[:list_id])
    new_contact_ids = (params[:contact_ids] || []).map(&:to_i)
    current_contact_ids = @list.contact_ids
    
    # Calculate contacts to add and remove
    contacts_to_add = new_contact_ids - current_contact_ids
    contacts_to_remove = current_contact_ids - new_contact_ids
    
    added_count = 0
    removed_count = 0
    
    # Add new contacts
    contacts_to_add.each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      next unless contact
      
      membership = @list.contact_list_memberships.build(contact: contact)
      if membership.save
        added_count += 1
      end
    end
    
    # Remove unchecked contacts
    contacts_to_remove.each do |contact_id|
      membership = @list.contact_list_memberships.find_by(contact_id: contact_id)
      if membership&.destroy
        removed_count += 1
      end
    end
    
    message = "Updated #{@list.name}: "
    message_parts = []
    message_parts << "added #{added_count} contacts" if added_count > 0
    message_parts << "removed #{removed_count} contacts" if removed_count > 0
    message_parts << "no changes" if added_count == 0 && removed_count == 0
    message += message_parts.join(', ')
    
    render json: { 
      success: true, 
      message: message,
      added_count: added_count,
      removed_count: removed_count,
      contacts_count: @list.reload.contacts_count,
      redirect_url: admin_list_path(@list)
    }
  end
end
