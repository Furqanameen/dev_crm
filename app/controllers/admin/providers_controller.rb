class Admin::ProvidersController < Admin::BaseController
  before_action :set_provider, only: [:show, :edit, :update, :destroy]

  def index
    @providers = Provider.all.order(:name)
    
    @providers = @providers.where(channel: params[:channel]) if params[:channel].present?
    @providers = @providers.where(status: params[:status]) if params[:status].present?
    
    @channels = Provider.channels.keys
    @statuses = Provider.statuses.keys
  end

  def show
    @recent_schedules = @provider.schedules.includes(:template).limit(5).order(created_at: :desc)
    @stats = {
      total_schedules: @provider.schedules.count,
      active_schedules: @provider.schedules.where(state: [:scheduled, :sending]).count,
      total_messages: @provider.messages.count,
      sent_messages: @provider.messages.sent.count,
      failed_messages: @provider.messages.failed.count
    }
  end

  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)
    process_configuration_params
    
    if @provider.save
      redirect_to admin_provider_path(@provider), notice: 'Provider was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    process_configuration_params
    
    if @provider.update(provider_params)
      redirect_to admin_provider_path(@provider), notice: 'Provider was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @provider.schedules.any?
      redirect_to admin_providers_path, alert: 'Cannot delete provider with existing schedules.'
    else
      @provider.destroy
      redirect_to admin_providers_path, notice: 'Provider was successfully deleted.'
    end
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def provider_params
    params.require(:provider).permit(:name, :channel, :status, :description, configuration: {})
  end
  
  def process_configuration_params
    if params[:provider][:configuration_keys].present? && params[:provider][:configuration_values].present?
      keys = params[:provider][:configuration_keys].reject(&:blank?)
      values = params[:provider][:configuration_values].reject(&:blank?)
      
      configuration = {}
      keys.each_with_index do |key, index|
        configuration[key] = values[index] if values[index].present?
      end
      
      @provider.configuration = configuration
    end
  end
end
