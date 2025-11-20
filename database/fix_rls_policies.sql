-- Enable RLS on products if not already enabled
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- PRODUCTS POLICIES

-- Allow everyone to view products
CREATE POLICY "Allow public to view products"
ON products
FOR SELECT
TO public
USING (true);

-- Allow authenticated users to create products
CREATE POLICY "Allow authenticated users to create products"
ON products
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow users to update their own products
-- Using seller_email to match auth.jwt() ->> 'email'
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


-- POSTS POLICIES (Ensuring they exist and are correct)

-- Enable RLS on posts if not already enabled
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Allow everyone to view posts
-- DROP POLICY IF EXISTS "Allow public to view posts" ON posts; -- Uncomment to reset if needed
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
WITH CHECK (true);

-- Allow users to update their own posts
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
