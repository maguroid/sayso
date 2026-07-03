CREATE TABLE accounts (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  legacy_code TEXT,
  legacy_owner TEXT,
  balance INTEGER NOT NULL DEFAULT 0
);
