// Proxies Fragella fragrance search so FRAGELLA_API_KEY never reaches the browser.
const { applyCors } = require('./_cors');

module.exports = async (req, res) => {
  if (applyCors(req, res)) return;

  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET, OPTIONS');
    return res.status(405).json({ message: 'Method not allowed.' });
  }

  const apiKey = process.env.FRAGELLA_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ message: 'Fragrance search is not configured.' });
  }

  const search = String(req.query.search || '').trim();
  if (search.length < 3) {
    return res.status(400).json({ message: 'Search query must be at least 3 characters.' });
  }
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 50);

  const baseUrl = (process.env.FRAGELLA_BASE_URL || 'https://api.fragella.com/api/v1').replace(/\/+$/, '');
  const url = `${baseUrl}/fragrances?${new URLSearchParams({ search, limit: String(limit) })}`;

  try {
    const upstream = await fetch(url, {
      headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    });

    if (upstream.ok) {
      // Cache identical searches at the edge to stay under Fragella's rate limits.
      res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
    }
    res.setHeader('Content-Type', 'application/json');
    return res.status(upstream.status).send(await upstream.text());
  } catch (err) {
    console.error('[api/fragrances] Fragella request failed:', err);
    return res.status(502).json({ message: 'Fragrance search failed.' });
  }
};
