// Generates assets/.env for the Flutter web build from Vercel environment variables.
// Everything written here is bundled into the public site, so only browser-safe
// values belong in this list. Server secrets (GROQ_API_KEY, FRAGELLA_API_KEY) are
// read by the functions in /api instead.
const fs = require('fs');
const path = require('path');

const PUBLIC_KEYS = [
  'SUPABASE_URL',
  'SUPABASE_PUBLISHABLE_KEY',
  'SUPABASE_ANON_KEY',
  'SUPABASE_EXCHANGE_BUCKET',
  'CHAT_BACKEND_URL',
  'FRAGELLA_WIDGET_ID',
  'API_BASE_URL',
];

if (!process.env.SUPABASE_URL || !(process.env.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY)) {
  console.error('Missing SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (or SUPABASE_ANON_KEY) environment variables.');
  process.exit(1);
}

const lines = PUBLIC_KEYS.filter((key) => process.env[key]).map((key) => `${key}=${process.env[key]}`);

const target = path.join(__dirname, '..', 'assets', '.env');
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, lines.join('\n') + '\n');
console.log(`Wrote ${lines.length} public variables to assets/.env`);
