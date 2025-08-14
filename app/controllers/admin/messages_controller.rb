class Admin::MessagesController < Admin::BaseController
  before_action :set_message, only: [:show]

  def index
    @messages = Message.includes(:schedule, :contact, :message_events).order(created_at: :desc)
    
    # Filters
    @messages = @messages.where(status: params[:status]) if params[:status].present?
    @messages = @messages.where(channel: params[:channel]) if params[:channel].present?
    @messages = @messages.joins(:schedule).where(schedules: { id: params[:schedule_id] }) if params[:schedule_id].present?
    
    # Pagination
    @messages = @messages.page(params[:page]).per(50)
    
    # Filter options
    @statuses = Message.statuses.keys
    @channels = Message.channels.keys
    @schedules = Schedule.order(:name).pluck(:name, :id)
    
    # Stats
    @stats = {
      total: Message.count,
      queued: Message.queued.count,
      sent: Message.sent.count,
      delivered: Message.delivered.count,
      failed: Message.failed.count,
      bounced: Message.bounced.count
    }
  end

  def show
    @events = @message.message_events.order(created_at: :desc)
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end
end
