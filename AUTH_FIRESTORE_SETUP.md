# Firebase Authentication & Firestore Integration

## Overview

The app now uses **Firebase Authentication** for user sign-up/sign-in and **Firestore** as the primary database. User profiles are automatically synced to the `users` collection in Firestore whenever a user signs in or registers.

## Files Changed

### New Files

- `lib/models/user_profile.dart` — UserProfile model for Firestore document representation
- `lib/services/auth_service.dart` — AuthService to sync Firebase Auth users to Firestore
- `scripts/firestore_users_schema.md` — Documentation of the users collection structure

### Updated Files

- `lib/providers/auth_controller.dart` — Now calls AuthService to sync user data to Firestore after auth operations (signIn, register)
- `lib/main.dart` — Imports AuthService and provides it to AuthController via dependency injection
- `firestore.rules` — Added `users` collection access rules (each user can read all users, but write only their own profile)

## How It Works

### 1. User Registration / Sign-In

When a user signs up or signs in (via email or Google):

```
Firebase Auth (creates user) → AuthService.syncUserToFirestore() → Firestore users/{uid}
```

The `AuthService` automatically creates or updates the user document in the `users` collection.

### 2. User Document Structure

Each user document in Firestore has this structure:

```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://supabase.../profile.jpg",  // Optional; can be empty
  "createdAt": "2026-05-08T...",
  "updatedAt": "2026-05-08T..."
}
```

### 3. Firestore Rules

The security rules now allow:

- **Read**: All authenticated users can read the `users` collection (needed to fetch user info)
- **Write**: Each user can only write to their own profile document (`uid` must match `request.auth.uid`)
- **Delete**: Disabled (user profiles cannot be deleted via Firestore)

### 4. Profile Images

Profile images are stored in **Supabase Storage** (not Firestore):
- Upload to Supabase and store the public URL in the `photoUrl` field in Firestore
- The `photoUrl` is a string reference to the Supabase Storage URL

## Setup Steps

### 1. Deploy Firestore Rules

Run in the Supabase Firebase CLI or paste into Firebase Console:

```bash
firebase deploy --only firestore:rules
```

Or via Firebase Console:
1. Go to Firestore Database → Rules tab
2. Paste the contents of `firestore.rules`
3. Publish

### 2. Test Auth Flow

The app now auto-syncs users to Firestore. To verify:

1. Sign up or sign in via the app
2. Go to **Firebase Console → Firestore Database → Collections**
3. Look for a `users` collection with your user UID as a document ID
4. Verify the fields match the structure above

### 3. Profile Image Upload (Optional)

To add profile image support later:
1. Create a Supabase Storage bucket for profile images
2. Upload images to that bucket
3. Update the user profile with the public URL:
   ```dart
   await authService.updateUserProfile(
     uid: user.uid,
     photoUrl: 'https://supabase.../profile.jpg',
   );
   ```

## Troubleshooting

### Auth Not Syncing to Firestore

- Check **Firebase Console → Firestore Database → Rules**: ensure rules allow authenticated users to write to `users` collection
- Check app logs for errors in `AuthService.syncUserToFirestore()`
- Ensure `cloud_firestore` dependency is installed in `pubspec.yaml`

### User Can't Update Their Profile

- Verify the user is authenticated (`FirebaseAuth.instance.currentUser != null`)
- Ensure the UID matches the document ID in Firestore
- Check Firestore rules: `allow update: if isOwnUser(uid);` should permit the update

### Firestore Rules Not Updated

- Redeploy rules with `firebase deploy --only firestore:rules`
- Or update in Firebase Console and publish

## API Reference

### AuthService

```dart
// Sync user to Firestore (called automatically after auth)
await authService.syncUserToFirestore(
  authUser: user,
  displayName: 'John Doe',
);

// Fetch user profile from Firestore
final profile = await authService.getUserProfile(uid);

// Update user profile
await authService.updateUserProfile(
  uid: user.uid,
  displayName: 'New Name',
  photoUrl: 'https://...',
);

// Delete user profile (manual)
await authService.deleteUserProfile(uid);
```

### UserProfile Model

```dart
final profile = UserProfile(
  uid: 'abc123',
  email: 'user@example.com',
  displayName: 'John',
  photoUrl: 'https://...',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final json = profile.toMap(); // Convert to Map for Firestore
```

## Next Steps

- [ ] Deploy Firestore rules
- [ ] Test sign-up and sign-in flows
- [ ] Verify user documents appear in Firestore
- [ ] Add profile image upload flow (optional)
- [ ] Backfill existing auth users to Firestore (if needed)
