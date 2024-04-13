import { APIGatewayProxyEvent } from 'aws-lambda';
import { VarException } from './exceptions/VarException';
import { globalCases } from './exceptions/cases/globalCases';
import { RouteDefinition, AppRouter, HttpMethod } from './types/types';
import { analysisRoutes, fileRoutes, userRoutes } from './routes';

export const appRouter: AppRouter = async (event: APIGatewayProxyEvent) => {
  const {
    path,
    resource,
    pathParameters,
    queryStringParameters,
    httpMethod,
    body,
    requestContext
  } = event;

  console.log('path', path);
  console.log('queryStringParameters', queryStringParameters);

  if (requestContext && requestContext.identity) {
    const {identity: { sourceIp }} = requestContext;
    console.log('sourceIp', sourceIp);
  }

  const routes: RouteDefinition = {
    ...userRoutes,
    ...fileRoutes,
    ...analysisRoutes,
  };

  const handler = routes[resource]?.[httpMethod as HttpMethod];
  if (!handler) {
    throw new VarException(globalCases.notImplemented);
  }

  return {
    statusCode: 200,
    body: JSON.stringify(await handler(pathParameters, body, queryStringParameters)),
  };
};
