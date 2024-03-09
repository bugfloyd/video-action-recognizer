import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export type ServiceRouter = (
  event: APIGatewayProxyEvent
) => Promise<APIGatewayProxyResult>;

export interface CreateUserParams {
  given_name: string;
  family_name?: string;
  email: string;
}

export interface UpdateUserParams {
  given_name?: string;
  family_name?: string;
  email?: string;
}

export interface APIUser {
  username?: string;
  email: string;
  given_name: string;
  family_name: string;
  created_at?: Date;
  modified_at?: Date;
}