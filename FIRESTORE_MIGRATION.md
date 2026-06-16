# Firestore Migration Guide: Supabase → Firestore

## Overview

Your project has been migrated from a **mixed architecture** (Firebase Auth + Firestore Chat + Supabase Listings) to a **unified Firebase-first architecture**:

- ✅ **Firebase Auth** → User authentication
- ✅ **Firestore** → Users, Chat threads, Messages, **Exchange listings** (NEW)
- ✅ **Firebase Storage** → Exchange listing images (previously Supabase)
- ✅ **Supabase Storage** → Profile images only (unchanged)

## What Changed

### 1. **New Firestore Service** 
- [lib/services/firestore_exchange_service.dart](lib/services/firestore_exchange_service.dart)
- Replaces `ExchangeMarketplaceService` (Supabase-based)
- Handles all CRUD operations for exchange listings in Firestore

### 2. **Updated Models**
- [lib/models/exchange_listing.dart](lib/models/exchange_listing.dart)
- Added `fromFirestore()` factory to parse Firestore documents
- Kept `fromJson()` for backward compatibility with Supabase data

### 3. **Updated Provider**
- [lib/providers/exchange_listing_provider.dart](lib/providers/exchange_listing_provider.dart)
- Now uses `FirestoreExchangeService` instead of `ExchangeMarketplaceService`

### 4. **Updated Admin Panel**
- [admin-panel/server.js](admin-panel/server.js)
- Now writes to Firestore + Firebase Storage (primary)
- Falls back to local JSON storage if Firebase unavailable
- Added `firebase-admin` dependency

### 5. **Updated Firestore Rules**
- [firestore.rules](firestore.rules)
- Added `exchange_listings` collection rules
- All authenticated users can read listings
- Only owner can create/update/delete their listings

## Data Migration Steps

### Step 1: Deploy Firestore Rules

Run this to update security rules:

```bash
firebase deploy --only firestore:rules
```

Or manually in Firebase Console:
1. Go to **Firestore Database** → **Rules** tab
2. Paste the contents of `firestore.rules`
3. Click **Publish**

### Step 2: Migrate Existing Listings from Supabase

You have three options:

#### **Option A: Automatic Script (Recommended)**

Use this Node.js script to automatically migrate all listings:

```bash
cd scripts
npm install
node migrate-supabase-to-firestore.js
```

See `scripts/migrate-supabase-to-firestore.js` for details.

#### **Option B: Manual SQL Export + Import**

1. **Export from Supabase:**
   ```bash
   # In Supabase SQL Editor
   SELECT id, name, description, price, image_url, created_at, owner_id 
   FROM exchange_listings 
   ORDER BY created_at DESC;
   ```

2. **Copy each row and create Firestore document via Firebase Console:**
   - Go to Firestore → `exchange_listings` collection
   - Click **Add Document**
   - Document ID: use the listing `id` from Supabase
   - Fields:
     - `name` (string)
     - `description` (string)
     - `price` (number)
     - `imageUrl` (string - use Supabase URL or upload to Firebase Storage)
     - `ownerId` (string - use the owner's Firebase Auth UID)
     - `createdAt` (timestamp)

#### **Option C: Keep Old Data, Start Fresh**

Simply:
1. Deploy the new Firestore rules
2. Create new listings via the app (they'll go to Firestore)
3. Old Supabase listings will remain but won't be loaded by the app

## Testing the Migration

### 1. Test Listing Creation

**Web App:**
1. Sign in to the app
2. Go to **Admin Panel** (if available)
3. Create a new listing
4. Upload an image
5. Verify the listing appears in Firestore:
   - Firebase Console → Firestore → `exchange_listings` collection
   - Check the document has `ownerId` set to your Firebase Auth UID

**Check Firebase Storage:**
- Firebase Console → Storage
- Images should be stored under `exchange-listings/` folder

### 2. Test Listing Display

1. Go to **Marketplace** screen
2. Verify listings load from Firestore
3. Click on a listing to view details
4. Test chat functionality (should work if `ownerId` is set)

### 3. Verify Firestore Rules

Test that security rules work:

```javascript
// Authenticated user can read listings
db.collection('exchange_listings').get()

// Owner can create new listing
db.collection('exchange_listings').add({
  ownerId: firebaseAuth.currentUser.uid,
  name: 'Test',
  description: 'Test',
  price: 100,
  imageUrl: 'https://...',
  createdAt: new Date()
})

// Non-owner cannot update listing
db.collection('exchange_listings').doc(listingId).update({...})  // Should fail
```

## Admin Panel Setup

### Local Development (No Firebase)

If you don't have Firebase credentials yet:

```bash
cd admin-panel
npm install
npm start
```

The admin panel will use **local JSON storage** (`data/exchange_listings.json`) and images stored in `public/uploads/`.

### Production (With Firebase)

Create a `.env` file in `admin-panel/`:

```env
ADMIN_PASSWORD=your_secure_password
FIREBASE_PROJECT_ID=scentswapperfumes
FIREBASE_CREDENTIALS_PATH=path/to/service-account-key.json
```

Or use the `GOOGLE_APPLICATION_CREDENTIALS` environment variable (recommended for cloud deployment).

Then:

```bash
cd admin-panel
npm install
npm start
```

Images will be uploaded to **Firebase Storage**, and listings to **Firestore**.

## Troubleshooting

### Listings Don't Appear in Firestore

- ✅ Check Firestore rules are deployed (`firebase deploy --only firestore:rules`)
- ✅ Check user is authenticated (signed in)
- ✅ Check browser console for errors (F12 → Console)
- ✅ Check Firestore database is active (Firebase Console → Firestore)

### Images Not Uploading

- ✅ Check Firebase Storage is enabled (Firebase Console → Storage)
- ✅ Check storage rules allow authenticated users to write:
  ```firestore
  match /exchange-listings/{allPaths=**} {
    allow read, write: if request.auth != null;
  }
  ```
- ✅ Check image file size is under 50MB

### Chat Not Available for Listings

- ✅ Ensure `ownerId` is set on the listing document
- ✅ Check the format of `ownerId` matches Firebase Auth UID
- ✅ Verify buyer and seller are different users

### Admin Panel Can't Connect to Firebase

- ✅ Check `FIREBASE_PROJECT_ID` is correct
- ✅ Verify service account credentials file exists and is readable
- ✅ Check `GOOGLE_APPLICATION_CREDENTIALS` environment variable if using that method
- ✅ For local dev without Firebase, the admin panel falls back to local JSON storage

## New Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Web App                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
        ┌──────────────────────────────────┐
        │        Firebase Services         │
        ├──────────────────────────────────┤
        │ 🔐 Auth (Email + Google)        │
        │ 📄 Firestore:                   │
        │    - users/                     │
        │    - exchange_listings/ (NEW)   │
        │    - exchange_threads/          │
        │    - messages/                  │
        │ 🖼️  Storage:                     │
        │    - exchange-listings/         │
        └──────────────────────────────────┘
                    ↙            ↘
        ┌─────────────┐    ┌──────────────┐
        │ Supabase    │    │ Admin Panel  │
        │ Storage     │    │ (Node.js)    │
        │ (Profiles)  │    │              │
        └─────────────┘    └──────────────┘
```

## Rollback Plan

If you need to revert to Supabase listings:

1. **Keep the old ExchangeMarketplaceService** (still in codebase)
2. **Revert ExchangeListingProvider** to use `ExchangeMarketplaceService`
3. **Revert main.dart** provider setup
4. **Redeploy the app**

However, **this is not recommended**. The Firestore architecture is cleaner and more integrated.

## Next Steps

1. ✅ Deploy Firestore rules: `firebase deploy --only firestore:rules`
2. ✅ Migrate existing Supabase listings to Firestore (Option A/B/C above)
3. ✅ Test listing creation and display
4. ✅ Test chat functionality with migrated listings
5. ✅ Update admin panel `.env` with Firebase credentials (if using production Firebase)
6. ✅ Remove old Supabase code when confident (optional)

## Support

If you encounter issues:

1. Check browser console (F12 → Console) for error messages
2. Check Firebase Console → Firestore for document structure
3. Check Firebase Console → Storage for uploaded images
4. Review Firestore rules for permission issues
5. Check admin panel logs for migration errors

---

**Migration Date:** 2026-05-08
**Architecture:** Firebase-first (Unified)
**Status:** Ready for testing
