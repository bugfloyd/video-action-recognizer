import {
  APIGatewayProxyEvent,
  APIGatewayProxyHandler,
  APIGatewayProxyResult,
} from 'aws-lambda';
import { awsRegion } from './variables';
import { VarException, configCases } from './exceptions';
import { ServiceRouter } from './types';

const validateSystemConfig = () => {
  if (!awsRegion) {
    console.error('ERROR - No REGION environment variable found');
    throw new VarException(configCases.badConfig);
  }
};

export const handlerFactory = (
  serviceRouter: ServiceRouter,
  lambdaConfigValidator: () => void
): APIGatewayProxyHandler => {
  const handler = async (
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> => {
    try {
      validateSystemConfig();
      lambdaConfigValidator();
      return await serviceRouter(event);
    } catch (error) {
      if (error instanceof VarException) {
        return {
          statusCode: error.code,
          body: JSON.stringify({
            message: error.message,
          }),
        };
      } else {
        return {
          statusCode: 500,
          body: JSON.stringify({
            message: 'An unexpected error occured',
          }),
        };
      }
    }
  };

  return handler;
};
