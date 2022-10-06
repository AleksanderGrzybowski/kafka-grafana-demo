require "kafka"
$stdout.sync = true 
$stdin.sync = true

kafka_url = "kafka:9092"
kafka_topic = "tasks"
kafka_consumer_group = kafka_topic
spike_size = 1000

def push_task(kafka_client, topic, message)
  puts "Pushing #{message}."
  kafka_client.deliver_message(message, topic: topic, partition_key: message, key: message)
end


puts "Connecting to Kafka #{kafka_url}..."
kafka = Kafka.new(kafka_url)
puts "Connected."

if kafka.topics.include?(kafka_topic)
  puts "Topic #{kafka_topic} already present, skipping creation."
else
  puts "Creating #{kafka_topic} topic..."
  kafka.create_topic(kafka_topic, num_partitions: 1, replication_factor: 1)
  puts "Topic created."
end

sleep 2 # For some reason this is needed (?)

puts "Pushing initial spike of #{spike_size} tasks..."
1.upto(spike_size) do |i|
  push_task(kafka, kafka_topic, "spike - #{i}")
end

sleep 2 # For some reason this is needed (?)

1.upto(1_000_000_000) do |i|
  message = "task - #{i}"
  push_task(kafka, kafka_topic, message)
  sleep(0.1 * rand)
end

