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
