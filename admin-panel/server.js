const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs/promises');
const multer = require('multer');
const dotenv = require('dotenv');
const { randomUUID } = require('crypto');
const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5050;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const DEFAULT_OWNER_UID = String(process.env.DEFAULT_OWNER_UID || '').trim();
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_BUCKET = process.env.SUPABASE_BUCKET || 'exchange-listings';

const DATA_DIR = path.join(__dirname, 'data');
const EXCHANGE_DB_FILE = path.join(DATA_DIR, 'exchange_listings.json');
const UPLOAD_DIR = path.join(__dirname, 'public', 'uploads');

// Initialize Supabase
let supabase = null;
let supabaseReady = false;
if (SUPABASE_URL && (SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY)) {
  const supabaseKey = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY;
  supabase = createClient(SUPABASE_URL, supabaseKey);
  supabaseReady = true;
  console.log('✓ Supabase initialized for image storage');
} else {
  console.warn('⚠ Supabase not configured, falling back to local image storage');
}

// Initialize Firebase Admin (for Firestore)
let db = null;
let firebaseReady = false;
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
  }
  db = admin.firestore();
  firebaseReady = true;
  console.log('✓ Firebase Firestore initialized');
} catch (err) {
  console.warn('⚠ Firebase initialization failed:', err.message);
}

app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  next();
});
app.use('/uploads', express.static(UPLOAD_DIR));
app.use(express.static(path.join(__dirname, 'public')));

function safeFileName(originalName) {
  return originalName.replace(/[^a-zA-Z0-9._-]/g, '_').toLowerCase();
}

const storageConfig = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || '.jpg');
    const base = safeFileName(path.basename(file.originalname || 'image', ext));
    cb(null, `${Date.now()}_${base}${ext}`);
  },
});

const upload = multer({
  storage: storageConfig,
  limits: {
    fileSize: 50 * 1024 * 1024,
  },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype || !file.mimetype.startsWith('image/')) {
      cb(new Error('Only image files are allowed.'));
      return;
    }
    cb(null, true);
  },
});

async function ensureStorage() {
  await fs.mkdir(DATA_DIR, { recursive: true });
  await fs.mkdir(UPLOAD_DIR, { recursive: true });
  try {
    await fs.access(EXCHANGE_DB_FILE);
  } catch (_) {
    await fs.writeFile(EXCHANGE_DB_FILE, '[]', 'utf8');
  }
}

async function readExchangeListings() {
  const content = await fs.readFile(EXCHANGE_DB_FILE, 'utf8');
  const data = JSON.parse(content);
  return Array.isArray(data) ? data : [];
}

async function writeExchangeListings(items) {
  await fs.writeFile(EXCHANGE_DB_FILE, JSON.stringify(items, null, 2), 'utf8');
}

function requireAdmin(req, res, next) {
  const password = req.header('x-admin-password');
  if (!password || password !== ADMIN_PASSWORD) {
    return res.status(401).json({ message: 'Unauthorized admin access.' });
  }
  next();
}

app.get('/api/health', (req, res) => {
  res.json({ 
    ok: true, 
    service: 'scentswap-admin-panel',
    firebaseReady,
    supabaseReady,
  });
});

app.get('/api/config', (req, res) => {
  res.json({
    defaultOwnerUid: DEFAULT_OWNER_UID,
    ownerIdRequired: !DEFAULT_OWNER_UID,
  });
});

app.get('/api/exchange-listings', async (req, res) => {
  try {
    if (firebaseReady) {
      // Fetch from Firestore
      const snapshot = await db.collection('exchange_listings').orderBy('createdAt', 'desc').get();
      const data = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      }));
      return res.json(data);
    } else {
      // Fall back to local JSON
      const data = await readExchangeListings();
      return res.json(data);
    }
  } catch (error) {
    console.error('Failed to fetch listings:', error);
    res.status(500).json({ message: 'Failed to read listings.' });
  }
});

app.post('/api/exchange-listings', upload.single('image'), async (req, res) => {
  try {
    const { name, description, price } = req.body;
    const ownerId = String(req.body.ownerId || req.body.owner_id || DEFAULT_OWNER_UID || '').trim();

    if (!name || !description || !price) {
      return res.status(400).json({
        message: 'Missing required fields: name, description, price.',
      });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'Image is required.' });
    }

    const parsedPrice = Number(price);
    if (Number.isNaN(parsedPrice) || parsedPrice <= 0) {
      return res.status(400).json({ message: 'Price must be a valid positive number.' });
    }

    if (!ownerId) {
      return res.status(400).json({ message: 'ownerId is required. Set DEFAULT_OWNER_UID or submit ownerId.' });
    }

    const listingId = randomUUID();
    const safeName = safeFileName(req.file.originalname || 'image.jpg');
    const imageBuffer = await fs.readFile(req.file.path);

    let imageUrl = null;

    // Try to upload to Supabase Storage
    if (supabaseReady) {
      try {
        const storagePath = `exchange-listings/${listingId}_${safeName}`;
        const { error } = await supabase.storage
          .from(SUPABASE_BUCKET)
          .upload(storagePath, imageBuffer, {
            contentType: req.file.mimetype || 'image/jpeg',
            upsert: false,
          });

        if (error) {
          console.warn('Supabase upload warning:', error.message);
        } else {
          // Get public URL
          const { data: publicData } = supabase.storage
            .from(SUPABASE_BUCKET)
            .getPublicUrl(storagePath);
          imageUrl = publicData.publicUrl;
          console.log('✓ Image uploaded to Supabase:', imageUrl);
        }
      } catch (supabaseError) {
        console.warn('Supabase upload failed:', supabaseError.message);
      }
    }

    // If Supabase upload failed, use local storage
    if (!imageUrl) {
      imageUrl = `/uploads/${req.file.filename}`;
      console.log('Using local image storage:', imageUrl);
    }

    // Try to write to Firestore
    if (firebaseReady) {
      try {
        await db.collection('exchange_listings').doc(listingId).set({
          ownerId,
          name: String(name).trim(),
          description: String(description).trim(),
          price: parsedPrice,
          imageUrl: imageUrl,
          createdAt: admin.firestore.Timestamp.now(),
        });

        console.log('✓ Listing created in Firestore:', listingId);
        return res.status(201).json({
          id: listingId,
          ownerId,
          name: String(name).trim(),
          description: String(description).trim(),
          price: parsedPrice,
          imageUrl: imageUrl,
          createdAt: new Date().toISOString(),
        });
      } catch (firestoreError) {
        console.warn('Firestore write failed:', firestoreError.message);
      }
    }

    // Fall back to local JSON
    const items = await readExchangeListings();
    const item = {
      id: listingId,
      ownerId,
      name: String(name).trim(),
      description: String(description).trim(),
      price: parsedPrice,
      imageUrl,
      createdAt: new Date().toISOString(),
    };

    items.unshift(item);
    await writeExchangeListings(items);
    console.log('✓ Listing created in local JSON:', listingId);

    res.status(201).json(item);
  } catch (error) {
    console.error('Error creating listing:', error);
    res.status(500).json({ message: 'Failed to create listing.' });
  }
});

app.get('/api/exchange-listings/admin', requireAdmin, async (req, res) => {
  try {
    const data = await readExchangeListings();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Failed to read listings.' });
  }
});

app.delete('/api/exchange-listings/:id', requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    // Try to delete from Firestore
    if (firebaseReady) {
      try {
        const doc = await db.collection('exchange_listings').doc(id).get();
        if (doc.exists) {
          await db.collection('exchange_listings').doc(id).delete();
          console.log('✓ Listing deleted from Firestore:', id);
          return res.json({ ok: true });
        }
      } catch (firestoreError) {
        console.warn('Firestore delete failed:', firestoreError.message);
      }
    }

    // Fall back to local JSON
    const items = await readExchangeListings();
    const target = items.find((item) => item.id === id);

    if (!target) {
      return res.status(404).json({ message: 'Listing not found.' });
    }

    const nextItems = items.filter((item) => item.id !== id);
    await writeExchangeListings(nextItems);

    const imagePath = path.join(__dirname, 'public', target.imageUrl.replace(/^\//, ''));
    try {
      await fs.unlink(imagePath);
    } catch (_) {
      // No-op
    }

    console.log('✓ Listing deleted from local JSON:', id);
    res.json({ ok: true });
  } catch (error) {
    console.error('Error deleting listing:', error);
    res.status(500).json({ message: 'Failed to delete listing.' });
  }
});

app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ message: err.message });
  }
  if (err) {
    return res.status(400).json({ message: err.message || 'Request failed.' });
  }
  next();
});

ensureStorage()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`\n🚀 Admin Panel running on http://localhost:${PORT}`);
      console.log(`   Firebase Firestore: ${firebaseReady ? '✓ Ready' : '✗ Not configured'}`);
      console.log(`   Supabase Storage:   ${supabaseReady ? '✓ Ready' : '✗ Not configured'}\n`);
    });
  })
  .catch((err) => {
    console.error('Failed to start admin panel:', err);
    process.exit(1);
  });
