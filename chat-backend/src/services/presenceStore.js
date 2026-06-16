class PresenceStore {
  constructor() {
    this.userCounts = new Map();
  }

  connect(userId) {
    const nextCount = (this.userCounts.get(userId) || 0) + 1;
    this.userCounts.set(userId, nextCount);
    return nextCount === 1;
  }

  disconnect(userId) {
    const currentCount = this.userCounts.get(userId) || 0;
    if (currentCount <= 1) {
      this.userCounts.delete(userId);
      return true;
    }

    this.userCounts.set(userId, currentCount - 1);
    return false;
  }

  isOnline(userId) {
    return (this.userCounts.get(userId) || 0) > 0;
  }
}

function createPresenceStore() {
  return new PresenceStore();
}

module.exports = {
  PresenceStore,
  createPresenceStore,
};
