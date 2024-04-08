import { APIGatewayProxyEvent } from 'aws-lambda';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';
import { ServiceRouter } from './types/types';
import { UserService } from './services/userService';
import { FileService } from './services/fileService';
import { ResultService } from './services/resultService';
import {
  createFileRequestProps, createResultRequestProps,
  createUserProps,
  generateUploadSignedUrlRequestParams, updateFileRequestProps, updateResultRequestProps,
  updateUserProps,
} from './allowedBodyParamas';

const usersService = new UserService();
const fileService = new FileService();
const resultService = new ResultService();

type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

type RouteHandler = (
  event: APIGatewayProxyEvent,
  pathParams: PathParams
) => Promise<object | 'deleted'>;

interface RouteDefinition {
  [pattern: string]: {
    [method in HttpMethod]?: RouteHandler;
  };
}

const parseBody = <T>(
  event: APIGatewayProxyEvent,
  allowedKeys: Array<keyof Partial<T>>
): Partial<T> => {
  try {
    const requestBody: Partial<T> = event.body ? JSON.parse(event.body) : {};
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

const routeHandlers: RouteDefinition = {
  '/users': {
    GET: () => usersService.getUsers(),
    POST: (event: APIGatewayProxyEvent) =>
      usersService.registerUser(
        parseBody(event, createUserProps)
      ),
  },
  '/users/:userId': {
    GET: (_event, pathParams) =>
      usersService.getUser(getParam(pathParams, 'userId')),
    PATCH: (event, pathParams) =>
      usersService.updateUser(
        getParam(pathParams, 'userId'),
        parseBody(event, updateUserProps)
      ),
    DELETE: (_event, pathParams) =>
      usersService.deleteUser(getParam(pathParams, 'userId')),
  },
  '/files': {
    GET: () => fileService.getFiles(),
  },
  '/files/:userId/generate-signed-url': {
    POST: (event, pathParams) =>
      fileService.generateSignedUrl(
        getParam(pathParams, 'userId'),
        parseBody(event, generateUploadSignedUrlRequestParams)
      ),
  },
  '/files/:userId': {
    POST: (event, pathParams) =>
      fileService.createFile(
        getParam(pathParams, 'userId'),
        parseBody(event, createFileRequestProps)
      ),
    GET: (_event, pathParams) =>
      fileService.getUserFiles(getParam(pathParams, 'userId')),
  },
  '/files/:userId/:fileId': {
    GET: (_event, pathParams) =>
      fileService.getFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
    PATCH: (event, pathParams) =>
      fileService.updateFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        parseBody(event, updateFileRequestProps)
      ),
    DELETE: (_event, pathParams) =>
      fileService.deleteFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
  },

  '/results': {
    GET: () => resultService.getResults(),
  },
  '/results/:userId/:fileId': {
    POST: (event, pathParams) =>
      resultService.createResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        parseBody(event, createResultRequestProps)
      ),
    GET: (_event, pathParams) =>
      resultService.getFileResults(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
  },
  '/results/:userId/:fileId/:resultId': {
    GET: (_event, pathParams) =>
      resultService.getResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'resultId')
      ),
    PATCH: (event, pathParams) =>
      resultService.updateResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'resultId'),
        parseBody(event, updateResultRequestProps)
      ),
    DELETE: (_event, pathParams) =>
      resultService.deleteResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'resultId')
      ),
  },
};

type ParamName = 'userId' | 'fileId' | 'resultId';
type PathParams = {
  [paramName in ParamName]?: string;
};

const getParam = (pathParams: PathParams, paramName: ParamName): string => {
  if (pathParams[paramName]) {
    return <string>pathParams[paramName];
  }
  throw new VarException(globalCases.invalidPathParams);
};

const readPath = (event: APIGatewayProxyEvent): [string, PathParams] => {
  const { path } = event;
  const params: PathParams = {};
  let routeKey = path.replace(/\/+$/, ''); //remove trailing slashes
  if (!event.pathParameters) {
    return [routeKey, params];
  }

  const paramNames: ParamName[] = ['userId', 'fileId', 'resultId'];
  for (const param of paramNames) {
    const paramValue = event.pathParameters[param];
    if (paramValue) {
      params[param] = paramValue;
      routeKey = routeKey.replace(paramValue, `:${param}`);
    }
  }
  return [routeKey, params];
};

export const appRouter: ServiceRouter = async (event: APIGatewayProxyEvent) => {
  const { httpMethod } = event;
  const [routeKey, pathParams] = readPath(event);
  const handler = routeHandlers[routeKey]?.[httpMethod as HttpMethod];
  if (!handler) {
    throw new VarException(globalCases.notImplemented);
  }

  return {
    statusCode: 200,
    body: JSON.stringify(await handler(event, pathParams)),
  };
};
