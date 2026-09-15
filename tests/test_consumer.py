import pytest

from consumer.consumer import build_consumer_config


def test_consumer_config_requires_credentials():
    with pytest.raises(RuntimeError, match="KAFKA_BOOTSTRAP_SERVERS"):
        build_consumer_config({})


def test_consumer_config_has_secure_defaults():
    config = build_consumer_config(
        {
            "KAFKA_BOOTSTRAP_SERVERS": "pkc-example.us-east-1.aws.confluent.cloud:9092",
            "KAFKA_API_KEY": "key",
            "KAFKA_API_SECRET": "secret",
        }
    )

    assert config["security.protocol"] == "SASL_SSL"
    assert config["sasl.mechanisms"] == "PLAIN"
    assert config["sasl.username"] == "key"
    assert config["sasl.password"] == "secret"
    assert config["group.id"] == "payments-consumer"
    assert config["auto.offset.reset"] == "earliest"
