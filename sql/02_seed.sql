-- Seed 500 customers and 1,000 accounts (980 ACTIVE, 20 FROZEN for validation tests)
INSERT INTO customer (customer_id, full_name, email, phone)
SELECT
    'CUST' || LPAD(gs::TEXT, 4, '0'),
    'Customer ' || gs,
    'customer' || gs || '@bank.in',
    '98000' || LPAD(gs::TEXT, 5, '0')
FROM generate_series(1, 500) AS gs
ON CONFLICT DO NOTHING;

INSERT INTO account (account_id, customer_id, balance, status)
SELECT
    'ACC' || LPAD(gs::TEXT, 4, '0'),
    'CUST' || LPAD(((gs - 1) % 500 + 1)::TEXT, 4, '0'),
    500000.00,
    CASE WHEN gs > 980 THEN 'FROZEN' ELSE 'ACTIVE' END
FROM generate_series(1, 1000) AS gs
ON CONFLICT DO NOTHING;
