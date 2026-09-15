output "payments_raw_topic" {
  value = confluent_kafka_topic.payments_raw.id
}

output "payments_processed_topic" {
  value = confluent_kafka_topic.payments_processed.id
}

output "payments_suspicious_topic" {
  value = confluent_kafka_topic.payments_suspicious.id
}

output "flink_compute_pool_id" {
  value = try(confluent_flink_compute_pool.payments[0].id, null)
}
