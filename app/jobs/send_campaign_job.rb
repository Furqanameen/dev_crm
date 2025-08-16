class SendCampaignJob < ApplicationJob
  queue_as :default
  
  def perform(schedule_id)
    schedule = Schedule.find(schedule_id)
    
    Rails.logger.info "Processing campaign job for Schedule ID: #{schedule_id}"
    
    # Ensure we have a Brevo provider
    unless schedule.provider&.name&.downcase&.include?('brevo')
      Rails.logger.error "Schedule #{schedule_id} does not have a Brevo provider"
      schedule.update!(state: :failed)
      return
    end
    
    # Use Brevo email sender
    sender = Brevo::EmailSender.new(schedule)
    result = sender.send_campaign

    if result[:success]
      Rails.logger.info "Campaign job completed successfully for Schedule ID: #{schedule_id}"
    else
      Rails.logger.error "Campaign job failed for Schedule ID: #{schedule_id}: #{result[:message]}"
    end
    
  rescue => e
    Rails.logger.error "Campaign job error for Schedule ID: #{schedule_id}: #{e.message}"
    schedule&.update!(state: :failed)
    raise e
  end
end
