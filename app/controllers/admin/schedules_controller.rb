class Admin::SchedulesController < Admin::BaseController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy, :materialize, :send_now, :pause, :resume]

  def index
    @schedules = Schedule.includes(:template, :provider, :target).order(created_at: :desc)
    
    @schedules = @schedules.where(state: params[:state]) if params[:state].present?
    @schedules = @schedules.where(template_id: params[:template_id]) if params[:template_id].present?
    @schedules = @schedules.where(provider_id: params[:provider_id]) if params[:provider_id].present?
    
    @schedules = @schedules.page(params[:page]).per(25) if respond_to?(:page)
    
    @states = Schedule.states.keys
    @templates = Template.order(:name).pluck(:name, :id)
    @providers = Provider.active.order(:name).pluck(:name, :id)
    
    @dashboard_stats = {
      total: Schedule.count,
      draft: Schedule.draft.count,
      scheduled: Schedule.scheduled.count,
      sending: Schedule.sending.count,
      completed: Schedule.completed.count,
      failed: Schedule.failed.count
    }
  end

  def show
    @schedule = Schedule.includes(:template, :provider, :target, :messages).find(params[:id])
    @messages = @schedule.messages.order(created_at: :desc).limit(100)
    @stats = {
      total_messages: @schedule.messages.count,
      sent_messages: @schedule.messages.sent.count,
      delivered_messages: @schedule.messages.delivered.count,
      failed_messages: @schedule.messages.failed.count,
      pending_messages: @schedule.messages.pending.count
    }
    
    @recent_events = MessageEvent.joins(:message)
                                 .where(messages: { schedule_id: @schedule.id })
                                 .order(created_at: :desc)
                                 .limit(20)
  end

  def new
    @schedule = Schedule.new
    @templates = Template.order(:name)
    @providers = Provider.active.order(:name)
    @contact_lists = List.active.order(:name)
  end

  def create
    @schedule = Schedule.new(schedule_params)
    
    if @schedule.save
      redirect_to admin_schedule_path(@schedule), notice: 'Schedule was successfully created.'
    else
      @templates = Template.order(:name)
      @providers = Provider.active.order(:name)
      @contact_lists = List.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @templates = Template.order(:name)
    @providers = Provider.active.order(:name)
    @contact_lists = List.active.order(:name)
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to admin_schedule_path(@schedule), notice: 'Schedule was successfully updated.'
    else
      @templates = Template.order(:name)
      @providers = Provider.active.order(:name)
      @contact_lists = List.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @schedule.messages.any?
      redirect_to admin_schedules_path, alert: 'Cannot delete schedule with existing messages.'
    else
      @schedule.destroy
      redirect_to admin_schedules_path, notice: 'Schedule was successfully deleted.'
    end
  end

  # Campaign management actions
  
  def materialize
    if @schedule.draft?
      if @schedule.materialize!
        redirect_to admin_schedule_path(@schedule), notice: 'Schedule has been materialized. Messages are ready to send.'
      else
        redirect_to admin_schedule_path(@schedule), alert: 'Failed to materialize schedule.'
      end
    else
      redirect_to admin_schedule_path(@schedule), alert: 'Only draft schedules can be materialized.'
    end
  end

  def send_now
    if @schedule.can_send?
      @schedule.update(send_at: Time.current, state: :sending)
      # Here you would typically enqueue a background job to actually send the messages
      # ScheduleSendJob.perform_later(@schedule)
      redirect_to admin_schedule_path(@schedule), notice: 'Schedule is now being sent.'
    else
      redirect_to admin_schedule_path(@schedule), alert: 'Schedule cannot be sent in its current state.'
    end
  end

  def pause
    if @schedule.sending?
      @schedule.update(state: :paused)
      redirect_to admin_schedule_path(@schedule), notice: 'Schedule has been paused.'
    else
      redirect_to admin_schedule_path(@schedule), alert: 'Only sending schedules can be paused.'
    end
  end

  def resume
    if @schedule.paused?
      @schedule.update(state: :sending)
      redirect_to admin_schedule_path(@schedule), notice: 'Schedule has been resumed.'
    else
      redirect_to admin_schedule_path(@schedule), alert: 'Only paused schedules can be resumed.'
    end
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:name, :template_id, :provider_id, :target_type, :target_id, 
                                      :send_at, :timezone, :state, :merge_data, :meta)
  end
end
