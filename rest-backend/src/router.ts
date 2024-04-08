import { APIGatewayProxyEvent } from 'aws-lambda';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';
import { ParamName, PathParams, ServiceRouter } from './types/types';
import { UserService } from './services/userService';
import { FileService } from './services/fileService';
import { AnalysisService } from './services/analysisService';
import {
  createFileRequestProps, createAnalysisRequestProps,
  createUserProps,
  generateUploadSignedUrlRequestParams, updateFileRequestProps, updateAnalysisRequestProps,
  updateUserProps,
} from './allowedBodyParamas';

const usersService = new UserService();
const fileService = new FileService();
const analysisService = new AnalysisService();

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

  '/analysis': {
    GET: () => analysisService.getAllAnalysis(),
  },
  '/analysis/:userId/:fileId': {
    POST: (event, pathParams) =>
      analysisService.createAnalysis(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        parseBody(event, createAnalysisRequestProps)
      ),
    GET: (_event, pathParams) =>
      analysisService.getFileAnalysis(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
  },
  '/analysis/:userId/:fileId/:analysisId': {
    GET: (_event, pathParams) =>
      analysisService.getAnalysis(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'analysisId')
      ),
    PATCH: (event, pathParams) =>
      analysisService.updateAnalysis(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'analysisId'),
        parseBody(event, updateAnalysisRequestProps)
      ),
    DELETE: (_event, pathParams) =>
      analysisService.deleteAnalysis(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'analysisId')
      ),
  },
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

  const paramNames: ParamName[] = ['userId', 'fileId', 'analysisId'];
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
