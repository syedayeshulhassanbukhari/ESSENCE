const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs/promises');
const multer = require('multer');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5050;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';

const DATA_DIR = path.join(__dirname, 'data');
const EXCHANGE_DB_FILE = path.join(DATA_DIR, 'exchange_listings.json');
const UPLOAD_DIR = path.join(__dirname, 'public', 'uploads');

app.use(cors());
app.use(express.json());
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
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: (req, file, cb) => {
    const allowedMimeTypes = new Set(['image/jpeg', 'image/jpg', 'image/png']);
    const extension = path.extname(file.originalname || '').toLowerCase();
    const allowedExtensions = new Set(['.jpg', '.jpeg', '.png']);

    if (!allowedMimeTypes.has(file.mimetype) || !allowedExtensions.has(extension)) {
      cb(new Error('Only JPG, JPEG, and PNG files are allowed.'));
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

    const items = await readExchangeListings();
    const item = {
      id: `${Date.now()}_${Math.floor(Math.random() * 1000000)}`,
      name: String(name).trim(),
      description: String(description).trim(),
      price: parsedPrice,
      imageUrl: `/uploads/${req.file.filename}`,
      createdAt: new Date().toISOString(),
    };

    items.unshift(item);
    await writeExchangeListings(items);
    res.status(201).json(item);
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
