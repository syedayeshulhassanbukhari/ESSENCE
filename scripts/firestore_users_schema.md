-- Firestore Initialization Script
-- This documents the users collection structure for Firebase Firestore.
-- Collections are created automatically in Firestore when you write data,
-- so this is for reference and to help initialize indexes if needed.

-- Collection: users
-- Document ID: Firebase Auth UID
-- Fields:
--   - email (string): User's email address
--   - displayName (string): User's display name
--   - photoUrl (string): URL to user's profile photo (optional, stored in Supabase Storage)
--   - createdAt (timestamp): Account creation timestamp
--   - updatedAt (timestamp): Last profile update timestamp

-- To create an index if needed for querying users by email:
-- Go to Firestore Console → Indexes → Create Index
-- Collection: users
-- Field: email (Ascending)
-- Query scope: Collection

-- Example user document structure:
-- {
--   "email": "user@example.com",
--   "displayName": "John Doe",
--   "photoUrl": "https://supabase.../path/to/photo.jpg",
--   "createdAt": Timestamp(2026, 5, 8, ...),
--   "updatedAt": Timestamp(2026, 5, 8, ...)
-- }
