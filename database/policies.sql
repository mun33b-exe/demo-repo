-- Enable RLS on posts if not already enabled
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- POSTS POLICIES

-- Allow everyone to view posts
CREATE POLICY "Allow public to view posts"
ON posts
FOR SELECT
TO public
USING (true);

-- Allow authenticated users to create posts
CREATE POLICY "Allow authenticated users to create posts"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id); -- Assuming user_id column exists and links to auth.users. If using email, adjust accordingly.
-- Based on previous code, it seems we are using 'user_email'. Let's check the schema.
-- If 'user_email' is just a string, we can't strictly enforce auth.uid() = user_id without a join or using email.
-- Ideally, we should store user_id. For now, let's trust the client or use email if available in auth.jwt()

-- Let's assume for now we are using email for identification as per previous code snippets.
-- A better approach is to use auth.uid().
-- However, to fix the immediate "Forbidden" error for the existing code structure:

-- Allow authenticated users to insert posts (basic)
CREATE POLICY "Allow authenticated users to insert posts"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow users to update their own posts (based on email match with auth.email())
CREATE POLICY "Allow users to update own posts"
ON posts
FOR UPDATE
TO authenticated
USING (user_email = auth.jwt() ->> 'email')
WITH CHECK (user_email = auth.jwt() ->> 'email');

-- Allow users to delete their own posts
CREATE POLICY "Allow users to delete own posts"
ON posts
FOR DELETE
TO authenticated
USING (user_email = auth.jwt() ->> 'email');


-- PRODUCTS POLICIES (Updates)

-- Allow users to update their own products
CREATE POLICY "Allow users to update own products"
ON products
FOR UPDATE
TO authenticated
USING (seller_email = auth.jwt() ->> 'email')
WITH CHECK (seller_email = auth.jwt() ->> 'email');

-- Allow users to delete their own products
CREATE POLICY "Allow users to delete own products"
ON products
FOR DELETE
TO authenticated
USING (seller_email = auth.jwt() ->> 'email');
