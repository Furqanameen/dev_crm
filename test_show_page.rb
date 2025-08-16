# Test MessageEventsController show page logic
puts 'Testing MessageEventsController#show logic...'

# Simulate what the controller does
event = MessageEvent.find(1)
message = event.message

puts "Event found: ID=#{event.id}, Type=#{event.event_type}"
puts "Message found: ID=#{message.id}, Status=#{message.status}"
puts "Contact: #{message.contact.display_name}"
puts "Event data keys: #{event.event_data.keys}"

# Test all the view logic
puts
puts 'Testing view helper methods:'
puts "  event.display_type: #{event.display_type}"
puts "  event.occurred_at: #{event.occurred_at}"
puts "  message.display_status: #{message.display_status}"
puts "  contact.display_name: #{message.contact.display_name}"

# Test related events
related_events = message.message_events.where.not(id: event.id)
puts "  related_events.count: #{related_events.count}"

puts
puts 'SUCCESS: Controller and view logic should work!'
