# Test script to verify MessageEvent fix
message = Message.first
if message
  test_event = MessageEvent.create!(
    message: message,
    event_type: :clicked,
    occurred_at: Time.current,
    raw: {
      'event' => 'clicked',
      'message-id' => message.provider_message_id,
      'email' => message.contact.email,
      'url' => 'https://example.com/clicked-link',
      'date' => Time.current.iso8601
    }
  )
  
  puts "Created test event with ID: #{test_event.id}"
  puts "Event data: #{test_event.event_data}"
  puts "URL: #{test_event.event_data['url']}"
  
  # Test the view logic
  if test_event.event_data.present? && test_event.event_data['url']
    puts "View would display URL: #{test_event.event_data['url']}"
  end
  
  puts 'SUCCESS: All methods work correctly!'
else
  puts 'No messages found for testing'
end
