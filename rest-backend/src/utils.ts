import { APIGatewayProxyEventPathParameters } from 'aws-lambda/trigger/api-gateway-proxy';
import { PathParameterName } from './types/types';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';

export const getPathParam = (
  pathParams: APIGatewayProxyEventPathParameters | null,
  paramName: PathParameterName
): string => {
  if (pathParams && pathParams[paramName]) {
    return <string>pathParams[paramName];
  }
  throw new VarException(globalCases.invalidPathParams);
};

export const parseBody = <T>(
  body: string | null,
  allowedKeys: Array<keyof Partial<T>>
): Partial<T> => {
  try {
    const requestBody: Partial<T> = body ? JSON.parse(body) : {};
    const cleanedRequestBody: Partial<T> = {};
    for (const key of allowedKeys) {
      if (requestBody && requestBody[key] !== undefined) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return cleanedRequestBody;
  } catch (error) {
    console.error(error);
    throw new VarException(globalCases.invalidBodyJson);
  }
};

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