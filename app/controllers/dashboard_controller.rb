class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_not_admin

  def index
    @user = current_user
  end

  private

  def ensure_not_admin
    redirect_to admin_root_path if current_user.admin?
  end
end
