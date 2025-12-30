-- LuxHome Authentication & Multi-Tenancy Migration
-- Run this in Supabase SQL Editor

-- =====================================================
-- 1. CREATE NEW TABLES
-- =====================================================

-- Properties table
CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_properties_code ON properties(code);
CREATE INDEX IF NOT EXISTS idx_properties_owner ON properties(owner_id);

-- Property members (many-to-many)
CREATE TABLE IF NOT EXISTS property_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(property_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_property_members_property ON property_members(property_id);
CREATE INDEX IF NOT EXISTS idx_property_members_user ON property_members(user_id);

-- User profiles (for phone number)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. HELPER FUNCTIONS
-- =====================================================

-- Generate unique 6-character property codes
CREATE OR REPLACE FUNCTION generate_property_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Auto-generate code on property creation
CREATE OR REPLACE FUNCTION set_property_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.code IS NULL OR NEW.code = '' THEN
    LOOP
      NEW.code := generate_property_code();
      EXIT WHEN NOT EXISTS (SELECT 1 FROM properties WHERE code = NEW.code);
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_property_code
  BEFORE INSERT ON properties
  FOR EACH ROW
  EXECUTE FUNCTION set_property_code();

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- 3. ADD property_id TO EXISTING TABLES
-- =====================================================

ALTER TABLE tasks ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE subtasks ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE workers ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE scheduled_visits ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE project_workers ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE progress_log_entries ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE history_entries ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES properties(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_tasks_property ON tasks(property_id);
CREATE INDEX IF NOT EXISTS idx_subtasks_property ON subtasks(property_id);
CREATE INDEX IF NOT EXISTS idx_projects_property ON projects(property_id);
CREATE INDEX IF NOT EXISTS idx_workers_property ON workers(property_id);
CREATE INDEX IF NOT EXISTS idx_scheduled_visits_property ON scheduled_visits(property_id);
CREATE INDEX IF NOT EXISTS idx_checklist_items_property ON checklist_items(property_id);
CREATE INDEX IF NOT EXISTS idx_project_workers_property ON project_workers(property_id);
CREATE INDEX IF NOT EXISTS idx_progress_log_entries_property ON progress_log_entries(property_id);
CREATE INDEX IF NOT EXISTS idx_history_entries_property ON history_entries(property_id);

-- =====================================================
-- 4. MIGRATE EXISTING DATA TO DEFAULT PROPERTY
-- =====================================================

-- Create a default property for existing data
-- NOTE: You'll need to create a user first or use an existing owner_id
-- For now, this is commented out. Run after you have a user:

/*
DO $$
DECLARE
  default_property_id UUID;
BEGIN
  -- Create default property
  INSERT INTO properties (name, code, owner_id)
  VALUES ('My Home', 'DEFAULT', 'YOUR_USER_ID_HERE')
  RETURNING id INTO default_property_id;

  -- Assign all existing data to default property
  UPDATE tasks SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE subtasks SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE projects SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE workers SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE scheduled_visits SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE checklist_items SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE project_workers SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE progress_log_entries SET property_id = default_property_id WHERE property_id IS NULL;
  UPDATE history_entries SET property_id = default_property_id WHERE property_id IS NULL;
END $$;
*/

-- =====================================================
-- 5. ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Properties
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their properties" ON properties;
CREATE POLICY "Users can view their properties"
  ON properties FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create properties" ON properties;
CREATE POLICY "Users can create properties"
  ON properties FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owners can update properties" ON properties;
CREATE POLICY "Owners can update properties"
  ON properties FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owners can delete properties" ON properties;
CREATE POLICY "Owners can delete properties"
  ON properties FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid());

-- Property Members
ALTER TABLE property_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view property members" ON property_members;
CREATE POLICY "Users can view property members"
  ON property_members FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can join properties" ON property_members;
CREATE POLICY "Users can join properties"
  ON property_members FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Owners can manage members" ON property_members;
CREATE POLICY "Owners can manage members"
  ON property_members FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

-- User Profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (id = auth.uid());

DROP POLICY IF EXISTS "Users can create own profile" ON user_profiles;
CREATE POLICY "Users can create own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid());

-- Tasks
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view tasks in their properties" ON tasks;
CREATE POLICY "Users can view tasks in their properties"
  ON tasks FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create tasks in their properties" ON tasks;
CREATE POLICY "Users can create tasks in their properties"
  ON tasks FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update tasks in their properties" ON tasks;
CREATE POLICY "Users can update tasks in their properties"
  ON tasks FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete tasks in their properties" ON tasks;
CREATE POLICY "Users can delete tasks in their properties"
  ON tasks FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Subtasks
ALTER TABLE subtasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view subtasks in their properties" ON subtasks;
CREATE POLICY "Users can view subtasks in their properties"
  ON subtasks FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create subtasks in their properties" ON subtasks;
CREATE POLICY "Users can create subtasks in their properties"
  ON subtasks FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update subtasks in their properties" ON subtasks;
CREATE POLICY "Users can update subtasks in their properties"
  ON subtasks FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete subtasks in their properties" ON subtasks;
CREATE POLICY "Users can delete subtasks in their properties"
  ON subtasks FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view projects in their properties" ON projects;
CREATE POLICY "Users can view projects in their properties"
  ON projects FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create projects in their properties" ON projects;
CREATE POLICY "Users can create projects in their properties"
  ON projects FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update projects in their properties" ON projects;
CREATE POLICY "Users can update projects in their properties"
  ON projects FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete projects in their properties" ON projects;
CREATE POLICY "Users can delete projects in their properties"
  ON projects FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Workers
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view workers in their properties" ON workers;
CREATE POLICY "Users can view workers in their properties"
  ON workers FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create workers in their properties" ON workers;
CREATE POLICY "Users can create workers in their properties"
  ON workers FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update workers in their properties" ON workers;
CREATE POLICY "Users can update workers in their properties"
  ON workers FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete workers in their properties" ON workers;
CREATE POLICY "Users can delete workers in their properties"
  ON workers FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Scheduled Visits
ALTER TABLE scheduled_visits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view scheduled_visits in their properties" ON scheduled_visits;
CREATE POLICY "Users can view scheduled_visits in their properties"
  ON scheduled_visits FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create scheduled_visits in their properties" ON scheduled_visits;
CREATE POLICY "Users can create scheduled_visits in their properties"
  ON scheduled_visits FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update scheduled_visits in their properties" ON scheduled_visits;
CREATE POLICY "Users can update scheduled_visits in their properties"
  ON scheduled_visits FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete scheduled_visits in their properties" ON scheduled_visits;
CREATE POLICY "Users can delete scheduled_visits in their properties"
  ON scheduled_visits FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Checklist Items
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view checklist_items in their properties" ON checklist_items;
CREATE POLICY "Users can view checklist_items in their properties"
  ON checklist_items FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create checklist_items in their properties" ON checklist_items;
CREATE POLICY "Users can create checklist_items in their properties"
  ON checklist_items FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update checklist_items in their properties" ON checklist_items;
CREATE POLICY "Users can update checklist_items in their properties"
  ON checklist_items FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete checklist_items in their properties" ON checklist_items;
CREATE POLICY "Users can delete checklist_items in their properties"
  ON checklist_items FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Project Workers
ALTER TABLE project_workers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view project_workers in their properties" ON project_workers;
CREATE POLICY "Users can view project_workers in their properties"
  ON project_workers FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create project_workers in their properties" ON project_workers;
CREATE POLICY "Users can create project_workers in their properties"
  ON project_workers FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update project_workers in their properties" ON project_workers;
CREATE POLICY "Users can update project_workers in their properties"
  ON project_workers FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete project_workers in their properties" ON project_workers;
CREATE POLICY "Users can delete project_workers in their properties"
  ON project_workers FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Progress Log Entries
ALTER TABLE progress_log_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view progress_log_entries in their properties" ON progress_log_entries;
CREATE POLICY "Users can view progress_log_entries in their properties"
  ON progress_log_entries FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create progress_log_entries in their properties" ON progress_log_entries;
CREATE POLICY "Users can create progress_log_entries in their properties"
  ON progress_log_entries FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update progress_log_entries in their properties" ON progress_log_entries;
CREATE POLICY "Users can update progress_log_entries in their properties"
  ON progress_log_entries FOR UPDATE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete progress_log_entries in their properties" ON progress_log_entries;
CREATE POLICY "Users can delete progress_log_entries in their properties"
  ON progress_log_entries FOR DELETE
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- History Entries
ALTER TABLE history_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view history_entries in their properties" ON history_entries;
CREATE POLICY "Users can view history_entries in their properties"
  ON history_entries FOR SELECT
  TO authenticated
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create history_entries in their properties" ON history_entries;
CREATE POLICY "Users can create history_entries in their properties"
  ON history_entries FOR INSERT
  TO authenticated
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 6. STORAGE RLS POLICIES (FIXES PHOTO UPLOAD!)
-- =====================================================

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to upload photos
DROP POLICY IF EXISTS "Authenticated users can upload photos" ON storage.objects;
CREATE POLICY "Authenticated users can upload photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'photos');

-- Allow authenticated users to view photos
DROP POLICY IF EXISTS "Authenticated users can view photos" ON storage.objects;
CREATE POLICY "Authenticated users can view photos"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'photos');

-- Allow authenticated users to update photos
DROP POLICY IF EXISTS "Authenticated users can update photos" ON storage.objects;
CREATE POLICY "Authenticated users can update photos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'photos');

-- Allow authenticated users to delete photos
DROP POLICY IF EXISTS "Authenticated users can delete photos" ON storage.objects;
CREATE POLICY "Authenticated users can delete photos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'photos');

-- =====================================================
-- MIGRATION COMPLETE!
-- =====================================================
-- Next steps:
-- 1. Enable Email Auth in Supabase Dashboard > Authentication > Providers
-- 2. Run the commented-out migration section after creating your first user
-- 3. Update your Swift app to use authentication
