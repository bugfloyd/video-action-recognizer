import { UserController } from './UsersController';
import { VarException, configCases, globalCases } from './shared/exceptions';
import { userPoolId } from './variables';
import { UserException } from './UserExceptions';
import { ServiceRouter } from './shared/types';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { awsRegion } from './shared/variables';

const usersRouter: ServiceRouter = async (event) => {
  if (!userPoolId) {
    console.error('ERROR - No USER_POOL_ID environment variable found');
    throw new VarException(configCases.badConfig);
  }

  const { httpMethod, pathParameters } = event;
  const userId = pathParameters ? pathParameters['user_id'] : null;

  // Create a new User
  if (!userId && httpMethod === 'POST') {
    let requestBody;
    try {
      requestBody = event.body ? JSON.parse(event.body) : {};
    } catch (error) {
      console.error(error);
      throw new UserException(globalCases.invalidBodyJson);
    }

    const usersController = new UserController();
    const createdUser = await usersController.createUser(requestBody);
    return {
      statusCode: 200,
      body: JSON.stringify(createdUser),
    };
  }

  throw new VarException(globalCases.notImplemented);
};

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const validateSystemConfig = () => {
    if (!awsRegion) {
      console.error('ERROR - No REGION environment variable found');
      throw new VarException(configCases.badConfig);
    }
  };

  try {
    validateSystemConfig();
    return await usersRouter(event);
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
          message: 'An unexpected error occurred',
        }),
      };
    }
  }
};