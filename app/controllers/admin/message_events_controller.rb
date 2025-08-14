class Admin::MessageEventsController < Admin::BaseController
  before_action :set_message_event, only: [:show]

  def index
    @events = MessageEvent.includes(:message => [:schedule, :contact]).order(created_at: :desc)
    
    # Filters
    @events = @events.where(event_type: params[:event_type]) if params[:event_type].present?
    @events = @events.joins(:message).where(messages: { id: params[:message_id] }) if params[:message_id].present?
    @events = @events.where('occurred_at >= ?', params[:from_date]) if params[:from_date].present?
    @events = @events.where('occurred_at <= ?', params[:to_date]) if params[:to_date].present?
    
    # Pagination
    @events = @events.page(params[:page]).per(100)
    
    # Filter options
    @event_types = MessageEvent.event_types.keys
    
    # Stats
    @stats = {
      total: MessageEvent.count,
      delivered: MessageEvent.delivered.count,
      opened: MessageEvent.opened.count,
      clicked: MessageEvent.clicked.count,
      bounced: MessageEvent.bounced.count,
      failed: MessageEvent.failed.count
    }
  end

  def show
    @message = @event.message
  end

  private

  def set_message_event
    @event = MessageEvent.find(params[:id])
  end
end
