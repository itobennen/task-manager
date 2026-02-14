-- Task Manager: Supabase Setup
-- Dieses SQL im Supabase SQL Editor ausführen

-- ============================================================
-- ERSTINSTALLATION (nur bei neuer Tabelle)
-- ============================================================

-- Tabelle erstellen
CREATE TABLE IF NOT EXISTS tasks (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  text       text NOT NULL,
  category   text NOT NULL CHECK (category IN ('mgmt', 'infra', 'prod', 'priv')),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  user_id    uuid REFERENCES auth.users(id),
  done       boolean DEFAULT false,
  done_at    timestamptz
);

-- Index für Sortierung
CREATE INDEX IF NOT EXISTS idx_tasks_sort_order ON tasks (sort_order);

-- Row Level Security aktivieren
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- MIGRATION (wenn Tabelle bereits existiert)
-- Spalten hinzufügen — ignoriert Fehler wenn schon vorhanden
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='user_id') THEN
    ALTER TABLE tasks ADD COLUMN user_id uuid REFERENCES auth.users(id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='done') THEN
    ALTER TABLE tasks ADD COLUMN done boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='done_at') THEN
    ALTER TABLE tasks ADD COLUMN done_at timestamptz;
  END IF;
END $$;

-- ============================================================
-- RLS POLICIES — alte Policy droppen, neue user-basierte erstellen
-- ============================================================

-- Alte "Allow all" Policy entfernen (falls vorhanden)
DROP POLICY IF EXISTS "Allow all access" ON tasks;

-- Neue Policies: Nur eigene Tasks sehen/erstellen/ändern/löschen
CREATE POLICY "Users can view own tasks" ON tasks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON tasks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON tasks
  FOR DELETE USING (auth.uid() = user_id);
