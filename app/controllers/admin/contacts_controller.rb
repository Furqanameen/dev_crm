class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = policy_scope(Contact)
    
    # Apply search filter
    if params[:search].present?
      @contacts = @contacts.search(params[:search])
    end

    # Apply account type filter
    if params[:account_type].present?
      @contacts = @contacts.where(account_type: params[:account_type])
    end

    # Apply consent status filter
    if params[:consent_status].present?
      @contacts = @contacts.where(consent_status: params[:consent_status])
    end

    # Apply pagination (simple limit/offset approach)
    @page = (params[:page] || 1).to_i
    @per_page = 25
    @total_count = @contacts.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @contacts = @contacts.limit(@per_page).offset((@page - 1) * @per_page)

    @account_type_counts = Contact.group(:account_type).count
    @consent_status_counts = Contact.group(:consent_status).count
  end

  def show
    authorize @contact
  end

  def new
    @contact = Contact.new
    authorize @contact
  end

  def create
    @contact = Contact.new(contact_params)
    authorize @contact

    if @contact.save
      AuditLog.log_action(current_user, :create_contact, @contact, contact_params)
      redirect_to admin_contact_path(@contact), notice: 'Contact was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @contact
  end

  def update
    authorize @contact

    if @contact.update(contact_params)
      AuditLog.log_action(current_user, :update_contact, @contact, contact_params)
      redirect_to admin_contact_path(@contact), notice: 'Contact was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @contact
    
    AuditLog.log_action(current_user, :delete_contact, @contact, { email: @contact.email })
    @contact.destroy
    
    redirect_to admin_contacts_path, notice: 'Contact was successfully deleted.'
  end

  def export
    authorize Contact
    
    @contacts = policy_scope(Contact)
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@contacts), 
                  filename: "contacts_#{Date.current.strftime('%Y%m%d')}.csv"
      end
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :email, :mobile_number, :account_type, :full_name, :company_name,
      :role, :country, :city, :source, :consent_status, :notes, tags: []
    )
  end

  def generate_csv(contacts)
    CSV.generate(headers: true) do |csv|
      csv << [
        'Email', 'Mobile Number', 'Account Type', 'Full Name', 'Company Name',
        'Role', 'Country', 'City', 'Source', 'Tags', 'Notes', 'Consent Status', 'Created At'
      ]
      
      contacts.each do |contact|
        csv << [
          contact.email,
          contact.mobile_number,
          contact.account_type,
          contact.full_name,
          contact.company_name,
          contact.role,
          contact.country,
          contact.city,
          contact.source,
          contact.tags&.join(', '),
          contact.notes,
          contact.consent_status,
          contact.created_at.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end
    end
  end
end
