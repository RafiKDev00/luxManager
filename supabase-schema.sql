-- LuxHome Supabase Database Schema
-- Copy and paste this entire file into Supabase SQL Editor
-- (Project Dashboard → SQL Editor → New Query)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TASKS TABLE
-- ============================================
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    description TEXT,
    last_completed_date TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT false,
    completed_subtasks INTEGER DEFAULT 0,
    total_subtasks INTEGER DEFAULT 0,
    is_recurring BOOLEAN DEFAULT false,
    recurring_interval INTEGER,
    recurring_unit TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SUBTASKS TABLE
-- ============================================
CREATE TABLE subtasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    photo_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PROJECTS TABLE
-- ============================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    next_step TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- WORKERS TABLE
-- ============================================
CREATE TABLE workers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    company TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    specialization TEXT NOT NULL,
    service_types TEXT[] DEFAULT '{}',
    schedule_type TEXT NOT NULL,
    is_scheduled BOOLEAN DEFAULT false,
    next_visit TIMESTAMPTZ,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PROJECT WORKER ASSIGNMENTS (Many-to-Many)
-- ============================================
CREATE TABLE project_workers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
    role TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(project_id, worker_id)
);

-- ============================================
-- PROGRESS LOG ENTRIES
-- ============================================
CREATE TABLE progress_log_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    text TEXT NOT NULL,
    photo_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SCHEDULED VISITS
-- ============================================
CREATE TABLE scheduled_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    date TIMESTAMPTZ NOT NULL,
    notes TEXT,
    is_done BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CHECKLIST ITEMS (for scheduled visits)
-- ============================================
CREATE TABLE checklist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES scheduled_visits(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- HISTORY ENTRIES
-- ============================================
CREATE TABLE history_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    action TEXT NOT NULL,
    item_type TEXT NOT NULL,
    item_name TEXT NOT NULL,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES for Performance
-- ============================================
CREATE INDEX idx_subtasks_task_id ON subtasks(task_id);
CREATE INDEX idx_progress_log_project_id ON progress_log_entries(project_id);
CREATE INDEX idx_scheduled_visits_worker_id ON scheduled_visits(worker_id);
CREATE INDEX idx_scheduled_visits_date ON scheduled_visits(date);
CREATE INDEX idx_checklist_items_visit_id ON checklist_items(visit_id);
CREATE INDEX idx_history_timestamp ON history_entries(timestamp DESC);
CREATE INDEX idx_project_workers_project_id ON project_workers(project_id);
CREATE INDEX idx_project_workers_worker_id ON project_workers(worker_id);

-- ============================================
-- UPDATED_AT TRIGGERS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subtasks_updated_at BEFORE UPDATE ON subtasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workers_updated_at BEFORE UPDATE ON workers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_progress_log_updated_at BEFORE UPDATE ON progress_log_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scheduled_visits_updated_at BEFORE UPDATE ON scheduled_visits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- For now, we'll make everything public since this is a single-user app
-- You can add auth later if needed
-- ============================================
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_log_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE scheduled_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE history_entries ENABLE ROW LEVEL SECURITY;

-- Allow anonymous access for now (single user app)
CREATE POLICY "Allow all access to tasks" ON tasks FOR ALL USING (true);
CREATE POLICY "Allow all access to subtasks" ON subtasks FOR ALL USING (true);
CREATE POLICY "Allow all access to projects" ON projects FOR ALL USING (true);
CREATE POLICY "Allow all access to workers" ON workers FOR ALL USING (true);
CREATE POLICY "Allow all access to project_workers" ON project_workers FOR ALL USING (true);
CREATE POLICY "Allow all access to progress_log_entries" ON progress_log_entries FOR ALL USING (true);
CREATE POLICY "Allow all access to scheduled_visits" ON scheduled_visits FOR ALL USING (true);
CREATE POLICY "Allow all access to checklist_items" ON checklist_items FOR ALL USING (true);
CREATE POLICY "Allow all access to history_entries" ON history_entries FOR ALL USING (true);
