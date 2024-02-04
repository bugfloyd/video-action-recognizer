import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export type ServiceRouter = (
  event: APIGatewayProxyEvent
) => Promise<APIGatewayProxyResult>;
