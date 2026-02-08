CREATE TABLE IF NOT EXISTS queue_qpoints (
  identifier VARCHAR(64) NOT NULL PRIMARY KEY,
  points INT NOT NULL DEFAULT 0,
  expires_at INT NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_queue_qpoints_expires ON queue_qpoints (expires_at);