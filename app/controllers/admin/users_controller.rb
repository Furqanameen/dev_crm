class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :invite]

  def index
    @users = policy_scope(User).includes(:import_batches)
    
    # Apply search filter
    if params[:search].present?
      @users = @users.where("email ILIKE ?", "%#{params[:search]}%")
    end

    # Apply role filter
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end

    # Apply pagination (simple limit/offset approach)
    @page = (params[:page] || 1).to_i
    @per_page = 20
    @total_count = @users.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @users = @users.order(:email).limit(@per_page).offset((@page - 1) * @per_page)

    @role_counts = User.group(:role).count
  end

  def show
    authorize @user
    @import_batches = @user.import_batches.recent.limit(10)
    @audit_logs = @user.audit_logs.recent.limit(20) if defined?(AuditLog)
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    
    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete your own account.'
      return
    end

    if @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    else
      redirect_to admin_users_path, alert: 'Failed to delete user.'
    end
  end

  def invite
    authorize @user
    
    # Logic to send invitation email
    # This would typically use a mailer or invitation system
    redirect_to admin_user_path(@user), notice: 'Invitation sent successfully.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role, :confirmed_at)
  end
end
