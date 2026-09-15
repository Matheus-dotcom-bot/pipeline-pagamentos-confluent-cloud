import json
import os
import signal
import sys

from confluent_kafka import Consumer, KafkaException
from dotenv import load_dotenv

load_dotenv()


def build_consumer_config(environ=None):
    """Build Kafka consumer configuration without creating a network connection."""
    env = os.environ if environ is None else environ
    required = (
        "KAFKA_BOOTSTRAP_SERVERS",
        "KAFKA_API_KEY",
        "KAFKA_API_SECRET",
    )
    missing = [name for name in required if not env.get(name)]
    if missing:
        raise RuntimeError(
            "Missing required Kafka environment variables: " + ", ".join(missing)
        )

    return {
        "bootstrap.servers": env["KAFKA_BOOTSTRAP_SERVERS"],
        "security.protocol": "SASL_SSL",
        "sasl.mechanisms": "PLAIN",
        "sasl.username": env["KAFKA_API_KEY"],
        "sasl.password": env["KAFKA_API_SECRET"],
        "group.id": env.get("CONSUMER_GROUP", "payments-consumer"),
        "auto.offset.reset": env.get("AUTO_OFFSET_RESET", "earliest"),
    }


def run():
    running = True

    def stop_handler(signum, frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGINT, stop_handler)
    signal.signal(signal.SIGTERM, stop_handler)

    config = build_consumer_config()
    topic = os.getenv("KAFKA_TOPIC_PROCESSED", "payments.processed")
    consumer = Consumer(config)
    consumer.subscribe([topic])

    print(f"Consuming from {topic}...")

    try:
        while running:
            message = consumer.poll(1.0)
            if message is None:
                continue
            if message.error():
                raise KafkaException(message.error())

            payload = json.loads(message.value().decode("utf-8"))
            print(json.dumps(payload, ensure_ascii=False), flush=True)
    finally:
        consumer.close()
        print("Consumer stopped.", file=sys.stderr)


if __name__ == "__main__":
    run()
