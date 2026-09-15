import json
import os
import signal
import sys

from confluent_kafka import Consumer, KafkaException
from dotenv import load_dotenv

load_dotenv()

running = True


def stop_handler(signum, frame):
    global running
    running = False


signal.signal(signal.SIGINT, stop_handler)
signal.signal(signal.SIGTERM, stop_handler)

config = {
    "bootstrap.servers": os.environ["KAFKA_BOOTSTRAP_SERVERS"],
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "PLAIN",
    "sasl.username": os.environ["KAFKA_API_KEY"],
    "sasl.password": os.environ["KAFKA_API_SECRET"],
    "group.id": os.getenv("CONSUMER_GROUP", "payments-consumer"),
    "auto.offset.reset": os.getenv("AUTO_OFFSET_RESET", "earliest"),
}

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
