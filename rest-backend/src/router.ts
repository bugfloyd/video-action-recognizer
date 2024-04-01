import { APIGatewayProxyEvent } from 'aws-lambda';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';
import { UserController } from './controllers/userController';
import { ServiceRouter } from './types/types';
import { FileController } from './controllers/fileController';
import { ResultController } from './controllers/resultController';

const usersController = new UserController();
const fileController = new FileController();
const resultController = new ResultController();

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

const parseBody = (event: APIGatewayProxyEvent) => {
  try {
    return event.body ? JSON.parse(event.body) : {};
  } catch (error) {
    console.error(error);
    throw new VarException(globalCases.invalidBodyJson);
  }
};

const routeHandlers: RouteDefinition = {
  '/users': {
    GET: () => usersController.getUsers(),
    POST: (event: APIGatewayProxyEvent) =>
      usersController.createUser(parseBody(event)),
  },
  '/users/:userId': {
    GET: (_event, pathParams) =>
      usersController.getUser(getParam(pathParams, 'userId')),
    PATCH: (event, pathParams) =>
      usersController.updateUser(
        getParam(pathParams, 'userId'),
        parseBody(event)
      ),
    DELETE: (_event, pathParams) =>
      usersController.deleteUser(getParam(pathParams, 'userId')),
  },
  '/files': {
    GET: () => fileController.getFiles(),
  },
  '/files/:userId': {
    POST: (event, pathParams) =>
      fileController.createFile(
        getParam(pathParams, 'userId'),
        parseBody(event)
      ),
    GET: (_event, pathParams) =>
      fileController.getUserFiles(getParam(pathParams, 'userId')),
  },
  '/files/:userId/:fileId': {
    GET: (_event, pathParams) =>
      fileController.getFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
    PATCH: (event, pathParams) =>
      fileController.updateFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        parseBody(event)
      ),
    DELETE: (_event, pathParams) =>
      fileController.deleteFile(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
  },

  '/results': {
    GET: () => resultController.getResults(),
  },
  '/results/:userId/:fileId': {
    POST: (event, pathParams) =>
      resultController.createResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        parseBody(event)
      ),
    GET: (_event, pathParams) =>
      resultController.getFileResults(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId')
      ),
  },
  '/results/:userId/:fileId/:resultId': {
    GET: (_event, pathParams) =>
      resultController.getResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'resultId')
      ),
    PATCH: (event, pathParams) =>
      resultController.updateResult(
        getParam(pathParams, 'userId'),
        getParam(pathParams, 'fileId'),
        getParam(pathParams, 'resultId'),
        parseBody(event)
      ),
    DELETE: (_event, pathParams) =>
      resultController.deleteResult(
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
