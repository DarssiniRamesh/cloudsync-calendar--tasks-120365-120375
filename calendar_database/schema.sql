-- Calendar App PostgreSQL Schema
-- Tables: users, events, tasks, notifications, oauth_tokens
-- Includes relationships, constraints, indexes & basic seed data

-- SCHEMA RESET (for clean setup - REMOVE IN PRODUCTION!)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS oauth_tokens CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    clerk_id VARCHAR(255) NOT NULL UNIQUE,
    preferences JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- EVENTS TABLE
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    recurrence VARCHAR(64), -- e.g., "daily", "weekly", "none", or RFC format
    category VARCHAR(64),
    priority INTEGER, -- e.g., 1=High, 2=Med, 3=Low
    color VARCHAR(32),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT events_end_after_start CHECK (end_time > start_time)
);

CREATE INDEX idx_events_user_id ON events(user_id);

-- TASKS TABLE
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_time TIMESTAMPTZ,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    category VARCHAR(64),
    priority INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);

-- NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
    type VARCHAR(64) NOT NULL, -- e.g., email, push, sms
    scheduled_time TIMESTAMPTZ NOT NULL,
    sent_status BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_event_id ON notifications(event_id);

-- OAUTH TOKENS TABLE
CREATE TABLE oauth_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(64) NOT NULL, -- e.g., 'gmail', 'google'
    token TEXT NOT NULL,
    expires_at TIMESTAMPTZ,
    scopes TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_provider UNIQUE (user_id, provider)
);

CREATE INDEX idx_oauth_tokens_user_id ON oauth_tokens(user_id);

-- BASIC SEED DATA (Minimal users/events/tasks to verify setup)
INSERT INTO users (email, clerk_id, preferences)
VALUES 
    ('alice@example.com', 'clerk_alice', '{"theme":"light","timezone":"UTC"}'),
    ('bob@example.com', 'clerk_bob', '{"theme":"dark","timezone":"America/New_York"}');

INSERT INTO events (user_id, title, description, start_time, end_time, recurrence, category, priority, color)
VALUES 
    (1, 'Welcome Call', 'Meet and greet with the team', now() + INTERVAL '1 day', now() + INTERVAL '1 day 1 hour', 'none', 'Work', 2, 'blue'),
    (2, 'Yoga Class', 'Morning yoga session', now() + INTERVAL '2 days', now() + INTERVAL '2 days 1 hour', 'weekly', 'Health', 3, 'green');

INSERT INTO tasks (user_id, title, description, due_time, completed, category, priority)
VALUES 
    (1, 'Read onboarding docs', 'Review project onboarding materials', now() + INTERVAL '2 days', FALSE, 'Work', 1),
    (2, 'Buy groceries', 'Get milk and eggs', now() + INTERVAL '12 hours', FALSE, 'Personal', 2);

INSERT INTO notifications (user_id, event_id, type, scheduled_time, sent_status)
VALUES 
    (1, 1, 'email', now() + INTERVAL '22 hours', FALSE),
    (2, 2, 'push', now() + INTERVAL '1 day 20 hours', FALSE);

INSERT INTO oauth_tokens (user_id, provider, token, expires_at, scopes)
VALUES 
    (1, 'gmail', 'ya29.a0AfH6SMA...', now() + INTERVAL '7 days', ARRAY['email','profile','gmail.readonly']),
    (2, 'google', 'ya29.a0AfH6uAA...', now() + INTERVAL '6 days', ARRAY['profile']);

-- END OF SCHEMA

-- README / ENVIRONMENT / SETUP NOTES

-- To setup the database from this schema:
-- 1. Ensure you have a PostgreSQL server running (see startup.sh)
-- 2. Run this schema as the configured user (see .env or postgres.env):
--    psql -h localhost -U appuser -d myapp -p 5000 -f schema.sql
-- 3. Default connection info (see db_connection.txt and postgres.env):
--      POSTGRES_URL="postgresql://localhost:5000/myapp"
--      POSTGRES_USER="appuser"
--      POSTGRES_PASSWORD="dbuser123"
--      POSTGRES_DB="myapp"
--      POSTGRES_PORT="5000"
-- 4. If you use a different environment, update .env or db_visualizer/postgres.env accordingly.

-- After setup, you can view data using the provided Node.js DB visualizer (see db_visualizer/).
-- Note: Remove the DROP TABLE statements in production use to avoid data loss!
