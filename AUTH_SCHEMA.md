# LuxHome Authentication & Multi-Tenancy Schema

## New Tables

### 1. properties
```sql
CREATE TABLE properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,  -- 6-char code for joining (e.g., "ABC123")
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for fast code lookups
CREATE INDEX idx_properties_code ON properties(code);
CREATE INDEX idx_properties_owner ON properties(owner_id);
```

### 2. property_members
```sql
CREATE TABLE property_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',  -- 'owner', 'admin', 'member'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(property_id, user_id)  -- User can only be member once per property
);

CREATE INDEX idx_property_members_property ON property_members(property_id);
CREATE INDEX idx_property_members_user ON property_members(user_id);
```

### 3. user_profiles (extends auth.users)
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Modified Tables (add property_id to all existing tables)

```sql
-- Add property_id to all content tables
ALTER TABLE tasks ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE subtasks ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE projects ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE workers ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE scheduled_visits ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE checklist_items ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE project_workers ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE progress_log_entries ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;
ALTER TABLE history_entries ADD COLUMN property_id UUID REFERENCES properties(id) ON DELETE CASCADE;

-- Create indexes for filtering
CREATE INDEX idx_tasks_property ON tasks(property_id);
CREATE INDEX idx_subtasks_property ON subtasks(property_id);
CREATE INDEX idx_projects_property ON projects(property_id);
CREATE INDEX idx_workers_property ON workers(property_id);
CREATE INDEX idx_scheduled_visits_property ON scheduled_visits(property_id);
CREATE INDEX idx_checklist_items_property ON checklist_items(property_id);
CREATE INDEX idx_project_workers_property ON project_workers(property_id);
CREATE INDEX idx_progress_log_entries_property ON progress_log_entries(property_id);
CREATE INDEX idx_history_entries_property ON history_entries(property_id);
```

## Row Level Security (RLS) Policies

### Properties
```sql
-- Enable RLS
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Users can see properties they're members of
CREATE POLICY "Users can view their properties"
  ON properties FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM property_members WHERE property_id = id
    )
  );

-- Users can create properties (become owner)
CREATE POLICY "Users can create properties"
  ON properties FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Only owners can update their properties
CREATE POLICY "Owners can update properties"
  ON properties FOR UPDATE
  USING (auth.uid() = owner_id);
```

### Property Members
```sql
ALTER TABLE property_members ENABLE ROW LEVEL SECURITY;

-- Users can see members of properties they belong to
CREATE POLICY "Users can view property members"
  ON property_members FOR SELECT
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

-- Owners can add members
CREATE POLICY "Owners can add members"
  ON property_members FOR INSERT
  WITH CHECK (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

-- Users can join via code (handled in app logic)
CREATE POLICY "Users can join properties"
  ON property_members FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

### Content Tables (tasks, projects, workers, etc.)
```sql
-- Example for tasks (repeat for all content tables)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view tasks in their properties"
  ON tasks FOR SELECT
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create tasks in their properties"
  ON tasks FOR INSERT
  WITH CHECK (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update tasks in their properties"
  ON tasks FOR UPDATE
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete tasks in their properties"
  ON tasks FOR DELETE
  USING (
    property_id IN (
      SELECT property_id FROM property_members WHERE user_id = auth.uid()
    )
  );
```

### Photos Bucket
```sql
-- Allow authenticated users to upload/view photos for their properties
CREATE POLICY "Authenticated users can upload photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'photos');

CREATE POLICY "Authenticated users can view photos"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'photos');

CREATE POLICY "Authenticated users can delete photos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'photos');
```

## Sign-In Flow

1. **Sign Up**:
   - User enters: email, password, phone
   - Choose: "Create Property" or "Join Property"
   - If create: generate unique 6-char code
   - If join: enter existing code

2. **Sign In**:
   - User enters: email + property code
   - App looks up property by code
   - Authenticates user
   - Sets current property context

## Helper Functions

### Generate Property Code
```sql
CREATE OR REPLACE FUNCTION generate_property_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- Exclude similar chars
  code TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;
```

### Auto-generate code on property creation
```sql
CREATE OR REPLACE FUNCTION set_property_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.code IS NULL THEN
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
```

## Migration Notes

For existing data:
1. Create a default property for current data
2. Set property_id on all existing records
3. Make property_id NOT NULL after migration
