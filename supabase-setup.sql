-- Task Manager: Supabase Setup
-- Dieses SQL im Supabase SQL Editor ausführen

-- Tabelle erstellen
CREATE TABLE tasks (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  text       text NOT NULL,
  category   text NOT NULL CHECK (category IN ('mgmt', 'infra', 'prod', 'priv')),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Index für Sortierung
CREATE INDEX idx_tasks_sort_order ON tasks (sort_order);

-- Row Level Security aktivieren
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Jeder mit dem anon key darf alles (für einfache Nutzung)
CREATE POLICY "Allow all access" ON tasks
  FOR ALL
  USING (true)
  WITH CHECK (true);
