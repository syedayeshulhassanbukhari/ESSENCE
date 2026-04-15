# ScentSwap Admin Panel (Node.js)

This is a standalone Node.js admin panel for marketplace exchange listings.

## Features

- Admin-protected endpoints using `x-admin-password`
- Upload perfume images with `multer`
- Create listing fields: name, description, price, image
- View current listings
- Delete listings
- Stores data in `data/exchange_listings.json`
- Stores uploaded images in `public/uploads/`

## Run

1. Open terminal in `admin-panel`
2. Install dependencies:

```bash
npm install
```

3. Create env file:

```bash
copy .env.example .env
```

4. Update `ADMIN_PASSWORD` in `.env`
5. Start server:

```bash
npm run dev
```

6. Open:

`http://localhost:5050`

## API

- `GET /api/health`
- `GET /api/exchange-listings` (public)
- `POST /api/exchange-listings` (public + image upload)
- `GET /api/exchange-listings/admin` (admin password required)
- `DELETE /api/exchange-listings/:id` (admin password required)
