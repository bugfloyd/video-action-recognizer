import { APIGatewayProxyEvent } from 'aws-lambda';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';
import { UserController } from './controllers/userController';
import { ServiceRouter } from './types/types';
import { FileController } from './controllers/fileController';

const usersController = new UserController();
const fileController = new FileController();

type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

type RouteHandler = (
  event: APIGatewayProxyEvent,
  pathParams: PathParams
) => Promise<object | string>;

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
    // GET: () =>
    //   fileController.getFiles(),
    POST: (event: APIGatewayProxyEvent) =>
      fileController.createFile(parseBody(event)),
  },
  '/files/:fileId': {
    // GET: (event: APIGatewayProxyEvent) =>
    //   fileController.getUFile(parseFileId(event)),
    // PATCH: (event: APIGatewayProxyEvent) =>
    //   fileController.updateFile(parseFileId(event), parseBody(event)),
    // DELETE: (event: APIGatewayProxyEvent) =>
    //   fileController.deleteFile(parseFileId(event)),
  },
};

type PathParams = Record<string, string>;

const getParam = (
  pathParams: PathParams,
  paramName: 'userId' | 'fileId' | 'resultId'
): string => {
  if (pathParams[paramName]) {
    return pathParams[paramName];
  }
  throw new VarException(globalCases.invalidPathParams);
};

const readPathParams = (event: APIGatewayProxyEvent): PathParams => {
  const params: PathParams = {};
  if (!event.pathParameters) {
    return params;
  }

  if (event.pathParameters['user_id']) {
    params.userId = event.pathParameters['user_id'];
  }
  if (event.pathParameters['file_id']) {
    params.fileId = event.pathParameters['file_id'];
  }
  if (event.pathParameters['result_id']) {
    params.resultId = event.pathParameters['result_id'];
  }

  return params;
};

export const appRouter: ServiceRouter = async (event: APIGatewayProxyEvent) => {
  const { httpMethod, path } = event;
  const pathParams = readPathParams(event);
  let routeKey = path.replace(/\/+$/, ''); //remove trailing slashes

  for (const paramName in pathParams) {
    if (pathParams[paramName]) {
      routeKey = routeKey.replace(pathParams[paramName], `:${paramName}`);
    }
  }

  const handler = routeHandlers[routeKey]?.[httpMethod as HttpMethod];
  if (!handler) {
    throw new VarException(globalCases.notImplemented);
  }

  return {
    statusCode: 200,
    body: JSON.stringify(await handler(event, pathParams)),
  };
};
