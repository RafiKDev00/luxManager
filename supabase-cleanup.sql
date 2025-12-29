-- LuxHome Supabase Cleanup Script
-- Run this FIRST to drop all existing tables
-- Then run supabase-schema.sql

-- Drop all tables in reverse order (to respect foreign key constraints)
DROP TABLE IF EXISTS checklist_items CASCADE;
DROP TABLE IF EXISTS scheduled_visits CASCADE;
DROP TABLE IF EXISTS progress_log_entries CASCADE;
DROP TABLE IF EXISTS project_workers CASCADE;
DROP TABLE IF EXISTS history_entries CASCADE;
DROP TABLE IF EXISTS subtasks CASCADE;
DROP TABLE IF EXISTS workers CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;

-- Drop the trigger function if it exists
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
