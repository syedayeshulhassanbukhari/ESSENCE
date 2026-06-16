const { requireString } = require('../utils/validation');

class ListingService {
  constructor({ db }) {
    this.db = db;
  }

  async getListingForChat(listingId, requesterId) {
    const id = requireString(listingId, 'listingId');
    console.log('[ListingService] Getting listing:', id, 'for requester:', requesterId);
    const listingRef = this.db.collection('exchange_listings').doc(id);
    const snapshot = await listingRef.get();

    if (!snapshot.exists) {
      console.error('[ListingService] Listing not found:', id);
      const error = new Error('Listing not found.');
      error.code = 'listing_not_found';
      error.statusCode = 404;
      throw error;
    }

    const data = snapshot.data() || {};
    console.log('[ListingService] Listing data:', data);
    const ownerId = typeof data.ownerId === 'string' ? data.ownerId.trim() : '';
    if (!ownerId) {
      console.error('[ListingService] Listing has no ownerId');
      const error = new Error('Listing owner is missing.');
      error.code = 'listing_owner_missing';
      error.statusCode = 422;
      throw error;
    }

    console.log('[ListingService] Listing retrieved successfully, ownerId:', ownerId);
    return {
      id: snapshot.id,
      ownerId,
      ...data,
    };
  }
}

function createListingService({ db }) {
  return new ListingService({ db });
}

module.exports = {
  ListingService,
  createListingService,
};
