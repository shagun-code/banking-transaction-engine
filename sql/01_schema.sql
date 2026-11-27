CREATE TABLE customer (
    customer_id VARCHAR(32) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE account (
    account_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) NOT NULL REFERENCES customer(customer_id),
    balance NUMERIC(18, 2) NOT NULL CHECK (balance >= 0.00),
    status VARCHAR(16) NOT NULL CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transaction_record (
    transaction_id VARCHAR(64) PRIMARY KEY,
    transaction_type VARCHAR(16) NOT NULL CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER')),
    source_account VARCHAR(32) NULL REFERENCES account(account_id),
    destination_account VARCHAR(32) NULL REFERENCES account(account_id),
    amount NUMERIC(18, 2) NOT NULL CHECK (amount > 0.00),
    status VARCHAR(16) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transaction_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(64) NOT NULL REFERENCES transaction_record(transaction_id),
    worker_thread VARCHAR(64) NOT NULL,
    operation VARCHAR(16) NOT NULL,
    outcome VARCHAR(16) NOT NULL,
    duration_ms BIGINT NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE failed_transaction (
    failure_id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(64) NOT NULL REFERENCES transaction_record(transaction_id),
    error_category VARCHAR(48) NOT NULL,
    failure_reason TEXT NOT NULL,
    failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Workload-justified indexes
CREATE INDEX idx_account_customer_id ON account(customer_id);
CREATE INDEX idx_txn_source_account ON transaction_record(source_account) WHERE source_account IS NOT NULL;
CREATE INDEX idx_txn_dest_account ON transaction_record(destination_account) WHERE destination_account IS NOT NULL;
CREATE INDEX idx_txn_created_at_type ON transaction_record(created_at, transaction_type);
CREATE INDEX idx_failed_txn_category ON failed_transaction(error_category);
CREATE INDEX idx_audit_txn_id ON transaction_audit(transaction_id);
