const CHAT_SEPARATOR = '::';

function buildChatId({ listingId, userA, userB }) {
  const listing = requireNonEmptyString(listingId, 'listingId');
  const firstUser = requireNonEmptyString(userA, 'userA');
  const secondUser = requireNonEmptyString(userB, 'userB');

  if (listing.includes(CHAT_SEPARATOR) || firstUser.includes(CHAT_SEPARATOR) || secondUser.includes(CHAT_SEPARATOR)) {
    throw new Error('Chat identifiers cannot contain the separator token.');
  }

  const [leftUser, rightUser] = [firstUser, secondUser].sort();
  const id = `${listing}${CHAT_SEPARATOR}${leftUser}${CHAT_SEPARATOR}${rightUser}`;
  console.log("[CHAT_ID_GEN] Generated:", id, { listingId, userA, userB });
  return id;
}

function parseChatId(chatId) {
  console.log("[CHAT_ID_PARSE] Input:", chatId);
  const value = requireNonEmptyString(chatId, 'chatId');
  const parts = value.split(CHAT_SEPARATOR);
  if (parts.length !== 3) {
    console.error("[CHAT_ID_PARSE] Error: Expected 3 parts, got", parts.length);
    throw new Error('Invalid chatId format.');
  }

  const [listingId, userA, userB] = parts;
  const result = {
    listingId,
    participants: [userA, userB].sort(),
  };
  console.log("[CHAT_ID_PARSE] Success:", result);
  return result;
}

function requireNonEmptyString(value, fieldName) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${fieldName} is required.`);
  }

  return value.trim();
}

module.exports = {
  buildChatId,
  parseChatId,
  CHAT_SEPARATOR,
};
