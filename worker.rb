require "kafka"
$stdout.sync = true 
$stdin.sync = true

kafka_url = "kafka:9092"
kafka_tasks_topic = "tasks"
kafka_results_topic = "results"
kafka_consumer_group = kafka_tasks_topic

def process_message
  sleep(0.09 * rand)
end

puts "Connecting to Kafka #{kafka_url}..."
kafka = Kafka.new(kafka_url)
puts "Connected."

puts "Creating consumer group #{kafka_consumer_group}..."
consumer = kafka.consumer(group_id: kafka_consumer_group)
puts "Consumer group created."

if kafka.topics.include?(kafka_results_topic)
  puts "Topic #{kafka_results_topic} already present, skipping creation."
else
  puts "Creating #{kafka_results_topic} topic..."
  kafka.create_topic(kafka_results_topic, num_partitions: 1, replication_factor: 1)
  puts "Topic created."
end

puts "Subscribing to new events on #{kafka_tasks_topic}..."
consumer.subscribe(kafka_tasks_topic, start_from_beginning: false) 
puts "Subscribed."

trap("TERM") { consumer.stop }

puts "Starting blocking listener."
consumer.each_message do |message|
  puts "Processing message: #{message.value}."
  process_message()
  kafka.deliver_message(message.value, topic: kafka_results_topic)
  consumer.mark_message_as_processed(message)
  consumer.commit_offsets
end
