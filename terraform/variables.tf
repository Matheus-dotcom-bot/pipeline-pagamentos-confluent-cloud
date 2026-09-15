variable "confluent_cloud_api_key" {
  description = "Confluent Cloud organization API key."
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud organization API secret."
  type        = string
  sensitive   = true
}

variable "confluent_environment_id" {
  description = "Existing Confluent Cloud environment ID, for example env-abc123."
  type        = string
}

variable "kafka_cluster_id" {
  description = "Existing Confluent Cloud Kafka cluster ID, for example lkc-abc123."
  type        = string
}

variable "kafka_rest_endpoint" {
  description = "Kafka REST endpoint for the selected Confluent Cloud cluster."
  type        = string
}

variable "kafka_api_key" {
  description = "Kafka API key scoped to the selected cluster."
  type        = string
  sensitive   = true
}

variable "kafka_api_secret" {
  description = "Kafka API secret scoped to the selected cluster."
  type        = string
  sensitive   = true
}

variable "partitions" {
  description = "Number of partitions for each payment topic."
  type        = number
  default     = 3
}

variable "create_flink_compute_pool" {
  description = "Whether Terraform should create the Flink compute pool. Set false to avoid creating billable Flink capacity."
  type        = bool
  default     = false
}

variable "flink_compute_pool_name" {
  description = "Display name for the Flink compute pool."
  type        = string
  default     = "payments-streaming-pool"
}

variable "flink_cloud" {
  description = "Cloud provider for the Flink compute pool."
  type        = string
  default     = "AWS"
}

variable "flink_region" {
  description = "Cloud region for the Flink compute pool."
  type        = string
  default     = "us-east-1"
}

variable "flink_max_cfu" {
  description = "Maximum CFUs for the Flink compute pool."
  type        = number
  default     = 5
}
