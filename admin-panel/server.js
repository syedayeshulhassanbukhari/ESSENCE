const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs/promises');
const multer = require('multer');
const dotenv = require('dotenv');
const { createClient } = require('@supabase/supabase-js');
const { randomUUID } = require('crypto');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5050;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_PUBLISHABLE_KEY = process.env.SUPABASE_PUBLISHABLE_KEY;
const SUPABASE_BUCKET = process.env.SUPABASE_BUCKET || 'exchange-images';

const DATA_DIR = path.join(__dirname, 'data');
const EXCHANGE_DB_FILE = path.join(DATA_DIR, 'exchange_listings.json');
const UPLOAD_DIR = path.join(__dirname, 'public', 'uploads');

const supabaseKey = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_PUBLISHABLE_KEY || SUPABASE_ANON_KEY;
const supabase = SUPABASE_URL && supabaseKey
  ? createClient(SUPABASE_URL, supabaseKey)
  : null;

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

const storage = multer.diskStorage({
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
  storage,
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
  res.json({ ok: true, service: 'scentswap-admin-panel' });
});

app.get('/api/exchange-listings', async (req, res) => {
  try {
    const data = await readExchangeListings();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Failed to read listings.' });
  }
});

app.post('/api/exchange-listings', upload.single('image'), async (req, res) => {
  try {
    const { name, description, price } = req.body;

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

    if (!supabase) {
      return res.status(500).json({
        message: 'Missing SUPABASE_URL and a Supabase key (SERVICE_ROLE, PUBLISHABLE, or ANON) in admin-panel .env.',
      });
    }

    const listingId = randomUUID();
    const safeName = safeFileName(req.file.originalname || 'image.jpg');
    const objectPath = `exchange-listings/${listingId}_${safeName}`;
    const imageBuffer = await fs.readFile(req.file.path);

    const uploadResult = await supabase.storage
      .from(SUPABASE_BUCKET)
      .upload(objectPath, imageBuffer, {
        contentType: req.file.mimetype || 'image/jpeg',
        upsert: false,
      });

    if (uploadResult.error) {
      return res.status(500).json({ message: uploadResult.error.message });
    }

    const imageUrl = supabase.storage.from(SUPABASE_BUCKET).getPublicUrl(objectPath).data
      .publicUrl;

    const insertResult = await supabase
      .from('exchange_listings')
      .insert({
        id: listingId,
        name: String(name).trim(),
        description: String(description).trim(),
        price: parsedPrice,
        image_url: imageUrl,
      })
      .select()
      .single();

    if (insertResult.error) {
      return res.status(500).json({ message: insertResult.error.message });
    }

    const items = await readExchangeListings();
    const item = {
      id: listingId,
      name: String(name).trim(),
      description: String(description).trim(),
      price: parsedPrice,
      imageUrl,
      createdAt: new Date().toISOString(),
    };

    items.unshift(item);
    await writeExchangeListings(items);
    res.status(201).json(insertResult.data);
  } catch (error) {
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
      // No-op: image might already be missing.
    }

    res.json({ ok: true });
  } catch (error) {
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

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

ensureStorage()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Admin panel running on http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Failed to initialize admin panel storage.', error);
    process.exit(1);
  });
