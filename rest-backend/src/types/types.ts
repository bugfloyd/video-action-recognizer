import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { APIGatewayProxyEventPathParameters } from 'aws-lambda/trigger/api-gateway-proxy';

export type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

export type RouteHandler = (
  body: string | null,
  pathParams: APIGatewayProxyEventPathParameters | null
) => Promise<object | 'deleted'>;

export interface RouteDefinition {
  [pattern: string]: {
    [method in HttpMethod]?: RouteHandler;
  };
}

export type AppRouter = (
  event: APIGatewayProxyEvent
) => Promise<APIGatewayProxyResult>;

export interface EntityTimestamps {
  createdAt: string;
  updatedAt: string;
}

export type PathParameterName = 'userId' | 'fileId' | 'analysisId';