class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      total_contacts: Contact.count,
      contacts_this_month: Contact.where(created_at: 1.month.ago..Time.current).count,
      total_imports: current_user.import_batches.count,
      recent_imports: current_user.import_batches.completed.recent.limit(5),
      pending_imports: current_user.import_batches.processing.count
    }

    @recent_contacts = Contact.recent.limit(10)
    @chart_data = generate_chart_data
  end

  private

  def generate_chart_data
    # Generate data for the last 30 days
    30.days.ago.to_date.upto(Date.current).map do |date|
      {
        date: date.strftime("%m/%d"),
        contacts: Contact.where(created_at: date.beginning_of_day..date.end_of_day).count
      }
    end
  end
end
