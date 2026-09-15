-- Operational queries for validating the processed stream.

-- Count processed events by risk band.
SELECT risk_band, COUNT(*) AS total
FROM payments_enriched
GROUP BY risk_band;

-- Inspect suspicious events.
SELECT
  payment_id,
  customer_id,
  amount,
  payment_method,
  suspicion_reason
FROM payments_suspicious;
