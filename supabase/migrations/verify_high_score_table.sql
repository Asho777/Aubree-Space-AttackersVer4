/*
  # Verify high_score table structure and policies

  1. Verification
    - Ensure `high_score` table exists with correct structure
    - Verify RLS policies are properly configured
    - Add any missing policies
*/

-- First, let's make sure the table exists with the correct structure
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'high_score') THEN
    CREATE TABLE public.high_score (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      player_name text NOT NULL,
      score integer NOT NULL,
      date timestamptz DEFAULT now()
    );
    
    ALTER TABLE public.high_score ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Drop existing policies to avoid conflicts
DO $$ 
BEGIN
  -- Drop the select policy if it exists
  IF EXISTS (
    SELECT FROM pg_policies 
    WHERE tablename = 'high_score' 
    AND policyname = 'High scores are publicly viewable'
  ) THEN
    DROP POLICY "High scores are publicly viewable" ON public.high_score;
  END IF;
  
  -- Drop the insert policy if it exists
  IF EXISTS (
    SELECT FROM pg_policies 
    WHERE tablename = 'high_score' 
    AND policyname = 'Anyone can insert high scores'
  ) THEN
    DROP POLICY "Anyone can insert high scores" ON public.high_score;
  END IF;
END $$;

-- Recreate policies with correct permissions
CREATE POLICY "High scores are publicly viewable"
  ON public.high_score
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can insert high scores"
  ON public.high_score
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Ensure anon role has proper permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT ON public.high_score TO anon;
GRANT USAGE ON SEQUENCE public.high_score_id_seq TO anon;
