class Admin::ListsController < Admin::BaseController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = current_user.lists.recent.includes(:contact_list_memberships)
    
    # Apply pagination
    @page = (params[:page] || 1).to_i
    @per_page = 15
    @total_count = @lists.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @lists = @lists.limit(@per_page).offset((@page - 1) * @per_page)
  end

  def show
    @contacts = @list.contacts.recent.includes(:contact_list_memberships)
    
    # Apply pagination for contacts
    @page = (params[:page] || 1).to_i
    @per_page = 20
    @total_count = @contacts.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @contacts = @contacts.limit(@per_page).offset((@page - 1) * @per_page)
  end

  def new
    @list = current_user.lists.build
  end

  def create
    @list = current_user.lists.build(list_params)
    
    if @list.save
      respond_to do |format|
        format.html do
          if params[:redirect_to_contacts]
            redirect_to admin_contacts_path(list_id: @list.id), notice: 'List created! Now select contacts to add to this list.'
          else
            redirect_to admin_list_path(@list), notice: 'List was successfully created.'
          end
        end
        format.json { render json: { success: true, list: @list, message: 'List was successfully created.' } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @list.errors.full_messages } }
      end
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to admin_list_path(@list), notice: 'List was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to admin_lists_path, notice: 'List was successfully deleted.'
  end

  private

  def set_list
    @list = current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :description, :is_active)
  end
end
