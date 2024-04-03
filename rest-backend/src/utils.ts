export const isUUID4 = (str: string): boolean => {
  const regex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return regex.test(str);
};

export const validateUserId = (userId: string): boolean => {
  if (!userId || !isUUID4(userId)) {
    return false;
  }
  // ToDo: Check user existence
  return true;
};

export const isValidS3ObjectName = (key: string) => {
  // Check if non-empty
  if (!key) return false;

  // UTF-8 byte length check
  const utf8Length = encodeURI(key).split(/%..|./).length - 1;
  if (utf8Length < 1 || utf8Length > 1024) return false;

  // Regular expression to allow spaces, non-Latin characters, and ensure there's an extension
  // This pattern is quite permissive, but ensures there is a dot followed by one or more characters for the extension
  const regex = /^[\w\s\p{L}!_.*'()-]+\.+[\w\p{L}]{1,5}$/u;
  return regex.test(key);
}