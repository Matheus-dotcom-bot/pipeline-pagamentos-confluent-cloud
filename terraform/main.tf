terraform {
  required_version = ">= 1.6.0"

  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.85.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_kafka_topic" "payments_raw" {
  kafka_cluster {
    id = var.kafka_cluster_id
  }

  topic_name       = "payments.raw"
  partitions_count = var.partitions
  rest_endpoint    = var.kafka_rest_endpoint

  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}

resource "confluent_kafka_topic" "payments_processed" {
  kafka_cluster {
    id = var.kafka_cluster_id
  }

  topic_name       = "payments.processed"
  partitions_count = var.partitions
  rest_endpoint    = var.kafka_rest_endpoint

  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}

resource "confluent_kafka_topic" "payments_suspicious" {
  kafka_cluster {
    id = var.kafka_cluster_id
  }

  topic_name       = "payments.suspicious"
  partitions_count = var.partitions
  rest_endpoint    = var.kafka_rest_endpoint

  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}

resource "confluent_flink_compute_pool" "payments" {
  count = var.create_flink_compute_pool ? 1 : 0

  display_name = var.flink_compute_pool_name
  cloud        = var.flink_cloud
  region       = var.flink_region
  max_cfu      = var.flink_max_cfu

  environment {
    id = var.confluent_environment_id
  }
}
