/*
  # Create high_score table

  1. New Tables
    - `high_score`
      - `id` (uuid, primary key)
      - `player_name` (text, not null)
      - `score` (integer, not null)
      - `date` (timestamptz, default now())
  2. Security
    - Enable RLS on `high_score` table
    - Add policy for public read access
    - Add policy for public insert access
*/

CREATE TABLE IF NOT EXISTS high_score (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_name text NOT NULL,
  score integer NOT NULL,
  date timestamptz DEFAULT now()
);

ALTER TABLE high_score ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read high scores
CREATE POLICY "High scores are publicly viewable"
  ON high_score
  FOR SELECT
  TO public
  USING (true);

-- Allow anyone to insert high scores
CREATE POLICY "Anyone can insert high scores"
  ON high_score
  FOR INSERT
  TO public
  WITH CHECK (true);
