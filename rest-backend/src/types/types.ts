import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export type ServiceRouter = (
  event: APIGatewayProxyEvent
) => Promise<APIGatewayProxyResult>;

export interface EntityTimestamps {
  createdAt: string;
  updatedAt: string;
}

export type ParamName = 'userId' | 'fileId' | 'analysisId';

export type PathParams = {
  [paramName in ParamName]?: string;
};