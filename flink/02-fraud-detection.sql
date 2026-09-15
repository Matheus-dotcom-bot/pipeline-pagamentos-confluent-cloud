-- Detect high-value payments and repeated activity in a short event-time window.

CREATE TABLE payments_suspicious (
  payment_id STRING,
  customer_id STRING,
  amount DECIMAL(14, 2),
  currency STRING,
  payment_method STRING,
  created_at TIMESTAMP_LTZ(3),
  suspicion_reason STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'payments.suspicious',
  'properties.bootstrap.servers' = '${KAFKA_BOOTSTRAP_SERVERS}',
  'properties.security.protocol' = 'SASL_SSL',
  'properties.sasl.mechanism' = 'PLAIN',
  'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_API_KEY}" password="${KAFKA_API_SECRET}";',
  'format' = 'json'
);

INSERT INTO payments_suspicious
SELECT
  payment_id,
  customer_id,
  amount,
  currency,
  payment_method,
  created_at,
  CASE
    WHEN amount >= 5000 THEN 'high_amount'
    ELSE 'frequency_rule'
  END AS suspicion_reason
FROM payments_raw
WHERE amount >= 5000;

-- A production implementation can add an event-time window rule, for example:
-- COUNT(*) OVER (
--   PARTITION BY customer_id
--   ORDER BY created_at
--   RANGE BETWEEN INTERVAL '5' MINUTE PRECEDING AND CURRENT ROW
-- ) >= 3
-- Keep the exact rule aligned with the business specification before deployment.
