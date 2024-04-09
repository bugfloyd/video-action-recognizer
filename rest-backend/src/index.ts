import { VarException } from './exceptions/VarException';
import {
  cloudfrontDistributionDomain,
  cloudFrontPrivateKeySecretName,
  cloudFrontPublicKeyId, eventBusName,
  userPoolId,
} from './variables';
import { awsRegion } from './variables';
import { globalCases } from './exceptions/cases/globalCases';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { appRouter } from './router';

const validateSystemConfig = () => {
  if (!awsRegion) {
    console.error('ERROR - No REGION environment variable found');
    throw new VarException(globalCases.badConfig);
  }
  if (!userPoolId) {
    console.error('ERROR - No USER_POOL_ID environment variable found');
    throw new VarException(globalCases.badConfig);
  }

  if (!cloudfrontDistributionDomain) {
    console.error('ERROR - No CLOUDFRONT_DISTRIBUTION_DOMAIN environment variable found');
    throw new VarException(globalCases.badConfig);
  }

  if (!cloudFrontPrivateKeySecretName) {
    console.error('ERROR - No CLOUDFRONT_PRIVATE_KEY_SECRET_NAME environment variable found');
    throw new VarException(globalCases.badConfig);
  }

  if (!cloudFrontPublicKeyId) {
    console.error('ERROR - No CLOUDFRONT_PUBLIC_KEY_ID environment variable found');
    throw new VarException(globalCases.badConfig);
  }

  if (!eventBusName) {
    console.error('ERROR - No EVENT_BUS_NAME environment variable found');
    throw new VarException(globalCases.badConfig);
  }
};

const handleError = (error: unknown): APIGatewayProxyResult => {
  console.log('ERROR', error);
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
        message: 'An unexpected error occurred',
      }),
    };
  }
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    validateSystemConfig();
    return await appRouter(event);
  } catch (error) {
    return handleError(error)
  }
};
