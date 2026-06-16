#!/usr/bin/env node

/**
 * Migrate Exchange Listings from Supabase to Firestore
 * 
 * Usage:
 *   node migrate-supabase-to-firestore.js
 * 
 * Prerequisites:
 *   - SUPABASE_URL and SUPABASE_ANON_KEY in .env
 *   - FIREBASE_PROJECT_ID and GOOGLE_APPLICATION_CREDENTIALS in .env
 */

const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Missing Supabase credentials in .env');
  console.error('   Required: SUPABASE_URL, SUPABASE_ANON_KEY');
  process.exit(1);
}

if (!FIREBASE_PROJECT_ID) {
  console.error('❌ Missing Firebase project ID in .env');
  console.error('   Required: FIREBASE_PROJECT_ID');
  process.exit(1);
}

// Initialize Supabase
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Initialize Firebase Admin
try {
  if (process.env.FIREBASE_CREDENTIALS_PATH) {
    admin.initializeApp({
      credential: admin.credential.cert(require(process.env.FIREBASE_CREDENTIALS_PATH)),
      projectId: FIREBASE_PROJECT_ID,
    });
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      projectId: FIREBASE_PROJECT_ID,
    });
  } else {
    // Try default Firebase CLI credentials
    admin.initializeApp({
      projectId: FIREBASE_PROJECT_ID,
    });
  }
} catch (err) {
  console.error('❌ Failed to initialize Firebase:', err.message);
  process.exit(1);
}

const db = admin.firestore();

async function migrateListings() {
  console.log('🚀 Starting migration: Supabase → Firestore\n');

  try {
    // 1. Fetch all listings from Supabase
    console.log('📥 Fetching listings from Supabase...');
    const { data: listings, error } = await supabase
      .from('exchange_listings')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('❌ Failed to fetch from Supabase:', error.message);
      process.exit(1);
    }

    if (!listings || listings.length === 0) {
      console.log('ℹ️  No listings found in Supabase');
      process.exit(0);
    }

    console.log(`✓ Found ${listings.length} listings\n`);

    // 2. Prepare listings for Firestore
    console.log('⚙️  Preparing listings for Firestore...');
    const batch = db.batch();
    let successCount = 0;
    let errorCount = 0;

    for (const listing of listings) {
      try {
        const firestoreDoc = {
          ownerId: listing.owner_id || 'migrated-from-supabase',
          name: listing.name,
          description: listing.description,
          price: parseFloat(listing.price),
          imageUrl: listing.image_url,
          createdAt: listing.created_at
            ? admin.firestore.Timestamp.fromDate(new Date(listing.created_at))
            : admin.firestore.Timestamp.now(),
        };

        const docRef = db.collection('exchange_listings').doc(listing.id);
        batch.set(docRef, firestoreDoc);
        successCount++;
      } catch (err) {
        console.error(`  ⚠️  Skipping listing ${listing.id}:`, err.message);
        errorCount++;
      }
    }

    // 3. Commit batch
    console.log('💾 Committing to Firestore...');
    await batch.commit();

    console.log(`\n✅ Migration complete!\n`);
    console.log(`   📊 Statistics:`);
    console.log(`      ✓ Successfully migrated: ${successCount} listings`);
    console.log(`      ⚠️  Errors: ${errorCount} listings\n`);

    // 4. Verify migration
    console.log('🔍 Verifying migration...');
    const snapshot = await db.collection('exchange_listings').get();
    console.log(`   Firestore now contains: ${snapshot.size} documents\n`);

    // 5. Show sample document
    if (snapshot.size > 0) {
      const sampleDoc = snapshot.docs[0];
      console.log('📄 Sample document:');
      console.log(`   ID: ${sampleDoc.id}`);
      console.log(`   Data:`, JSON.stringify(sampleDoc.data(), null, 2));
    }

    console.log('\n🎉 All done! Your listings are now in Firestore.');
    console.log('   The app will automatically load them from Firestore.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  }
}

// Run migration
migrateListings();
