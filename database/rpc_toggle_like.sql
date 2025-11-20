-- Drop potentially ambiguous functions first
DROP FUNCTION IF EXISTS toggle_like(BIGINT);
DROP FUNCTION IF EXISTS toggle_like(UUID);

-- Create a function to toggle likes
-- This function bypasses RLS for the specific operation of updating the likes array
-- Updated to use UUID for post_id
CREATE OR REPLACE FUNCTION toggle_like(post_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_likes TEXT[];
  user_email TEXT;
BEGIN
  -- Get the current user's email
  user_email := auth.jwt() ->> 'email';
  
  -- Check if user is authenticated
  IF user_email IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get the current likes for the post
  SELECT likes INTO current_likes
  FROM posts
  WHERE id = post_id;

  -- Initialize array if null
  IF current_likes IS NULL THEN
    current_likes := ARRAY[]::TEXT[];
  END IF;

  -- Toggle the like
  IF user_email = ANY(current_likes) THEN
    -- Remove email from array
    current_likes := array_remove(current_likes, user_email);
  ELSE
    -- Add email to array
    current_likes := array_append(current_likes, user_email);
  END IF;

  -- Update the post
  UPDATE posts
  SET likes = current_likes
  WHERE id = post_id;
END;
$$;
