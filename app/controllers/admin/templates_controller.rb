class Admin::TemplatesController < Admin::BaseController
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  def index
    @templates = Template.includes(:schedules).order(:purpose, :name)
    
    @templates = @templates.where(purpose: params[:purpose]) if params[:purpose].present?
    @templates = @templates.where(default_provider: params[:provider]) if params[:provider].present?
    
    @purposes = Template.purposes.keys
    @providers = Provider.distinct.pluck(:name)
  end

  def show
    @recent_schedules = @template.schedules.includes(:provider).limit(5).order(created_at: :desc)
    @stats = {
      total_schedules: @template.schedules.count,
      active_schedules: @template.schedules.where(state: [:scheduled, :sending]).count,
      completed_schedules: @template.schedules.completed.count
    }
  end

  def new
    @template = Template.new
    @providers = Provider.active.group_by(&:channel)
  end

  def create
    @template = Template.new(template_params)
    
    if @template.save
      redirect_to admin_template_path(@template), notice: 'Template was successfully created.'
    else
      @providers = Provider.active.group_by(&:channel)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @providers = Provider.active.group_by(&:channel)
  end

  def update
    if @template.update(template_params)
      redirect_to admin_template_path(@template), notice: 'Template was successfully updated.'
    else
      @providers = Provider.active.group_by(&:channel)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @template.schedules.any?
      redirect_to admin_templates_path, alert: 'Cannot delete template with existing schedules.'
    else
      @template.destroy
      redirect_to admin_templates_path, notice: 'Template was successfully deleted.'
    end
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(
      :name, :purpose, :default_provider, :external_template_id,
      :subject, :html_body, :text_body,
      merge_schema: {}, meta: {}
    )
  end
end
