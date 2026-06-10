-- Migration: Create chat history table for AI Agent conversation memory
CREATE TABLE IF NOT EXISTS chat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index for fast retrieval of user conversation context
CREATE INDEX IF NOT EXISTS idx_chat_history_user_created ON chat_history(user_id, created_at ASC);
