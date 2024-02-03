import {
  APIGatewayProxyEvent,
  APIGatewayProxyHandler,
  APIGatewayProxyResult,
} from 'aws-lambda';
import { UserController } from './UsersController';
import { awsRegion, userPoolId } from './variables';
import { UserCases, UserException } from './UserCases';

const usersRouter = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const { httpMethod, pathParameters } = event;
  const userId = pathParameters ? pathParameters['user_id'] : null;

  // Create a new User
  if (!userId && httpMethod === 'POST') {
    const usersController = new UserController();
    const createdUser = await usersController.createUser(event);
    return {
      statusCode: 200,
      body: JSON.stringify(createdUser),
    };
  }

  throw new UserException(UserCases.notImplemented);
};

const validateSystemConfig = () => {
  if (!userPoolId) {
    console.error('ERROR - No USER_POOL_ID environment variable found');
    throw new UserException(UserCases.unexpextedError);
  }

  if (!awsRegion) {
    console.error('ERROR - No REGION environment variable found');
    throw new UserException(UserCases.unexpextedError);
  }
};

export const handler: APIGatewayProxyHandler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    validateSystemConfig();
    return await usersRouter(event);
  } catch (error) {
    if (error instanceof UserException) {
      return {
        statusCode: error.code,
        body: JSON.stringify({
          message: error.message,
        }),
      };
    } else {
      console.log('Nooooo');
      return {
        statusCode: 500,
        body: JSON.stringify({
          message: 'An unexpected error occured',
        }),
      };
    }
  }
};
