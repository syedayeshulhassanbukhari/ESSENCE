function requireString(value, fieldName, maxLength) {
  if (typeof value !== 'string') {
    throw new Error(`${fieldName} must be a string.`);
  }

  const trimmed = value.trim();
  if (!trimmed) {
    throw new Error(`${fieldName} is required.`);
  }

  if (maxLength && trimmed.length > maxLength) {
    throw new Error(`${fieldName} must not exceed ${maxLength} characters.`);
  }

  return trimmed;
}

function requireChatPayload(payload) {
  if (!payload || typeof payload !== 'object') {
    throw new Error('Invalid payload.');
  }

  return payload;
}

function sanitizeMessageText(text) {
  const value = requireString(text, 'text', Number(process.env.CHAT_MAX_MESSAGE_LENGTH || 1000));
  return value.replace(/\s+/g, ' ');
}

module.exports = {
  requireString,
  requireChatPayload,
  sanitizeMessageText,
};
