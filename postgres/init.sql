CREATE TABLE IF NOT EXISTS payments (
    payment_id UUID PRIMARY KEY,
    customer_id VARCHAR(64) NOT NULL,
    amount NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    currency CHAR(3) NOT NULL DEFAULT 'BRL',
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_payments_customer_created
    ON payments (customer_id, created_at);

INSERT INTO payments
(payment_id, customer_id, amount, currency, status, payment_method)
VALUES
('11111111-1111-1111-1111-111111111111', 'customer-001', 149.90, 'BRL', 'approved', 'pix'),
('22222222-2222-2222-2222-222222222222', 'customer-002', 820.00, 'BRL', 'approved', 'credit_card'),
('33333333-3333-3333-3333-333333333333', 'customer-003', 7500.00, 'BRL', 'approved', 'pix')
ON CONFLICT (payment_id) DO NOTHING;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS payments_updated_at ON payments;
CREATE TRIGGER payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
