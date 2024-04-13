import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import {
  APIGatewayProxyEventPathParameters,
  APIGatewayProxyEventQueryStringParameters,
} from 'aws-lambda/trigger/api-gateway-proxy';
import { APIUser } from './user';
import { GenerateUploadSignedUrlResponse, VideoFile } from './videoFile';
import { AnalysisAPI } from './analysis';

export type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

export type RouteHandler = (
  pathParams: APIGatewayProxyEventPathParameters | null,
  body: string | null,
  queryStringParameters : APIGatewayProxyEventQueryStringParameters | null,
) => Promise<
  | APIUser
  | APIUser[]
  | VideoFile
  | VideoFile[]
  | AnalysisAPI
  | AnalysisAPI[]
  | GenerateUploadSignedUrlResponse
  | 'deleted'
>;

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

export interface GenerateSignedUrlResponse {
  url: string;
  expiration: number;
}
