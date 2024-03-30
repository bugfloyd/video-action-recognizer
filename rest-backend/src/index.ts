import { UserController } from './controllers/userController';
import { UserException, VarException } from './exceptions/VarException';
import { userPoolId } from './variables';
import { ServiceRouter } from './types/types';
import { awsRegion } from './variables';
import { globalCases } from './exceptions/cases/globalCases';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

const usersRouter: ServiceRouter = async (event) => {
  if (!userPoolId) {
    console.error('ERROR - No USER_POOL_ID environment variable found');
    throw new VarException(globalCases.badConfig);
  }

  const { httpMethod, pathParameters } = event;
  const userId = pathParameters ? pathParameters['user_id'] : null;
  const usersController = new UserController();

  // Create a new User
  if (!userId && httpMethod === 'POST') {
    let requestBody;
    try {
      requestBody = event.body ? JSON.parse(event.body) : {};
    } catch (error) {
      console.error(error);
      throw new UserException(globalCases.invalidBodyJson);
    }
    const createdUser = await usersController.createUser(requestBody);
    return {
      statusCode: 200,
      body: JSON.stringify(createdUser),
    };
  } else if (!userId && httpMethod === 'GET') {
    const users = await usersController.getUsers();
    return {
      statusCode: 200,
      body: JSON.stringify(users),
    };
  } else if (userId && httpMethod === 'GET') {
    const user = await usersController.getUser(userId);
    return {
      statusCode: 200,
      body: JSON.stringify(user),
    };
  } else if (userId && httpMethod === 'PATCH') {
    let requestBody;
    try {
      requestBody = event.body ? JSON.parse(event.body) : {};
    } catch (error) {
      console.error(error);
      throw new UserException(globalCases.invalidBodyJson);
    }
    const updatedUser = await usersController.updateUser(userId, requestBody);
    return {
      statusCode: 200,
      body: JSON.stringify(updatedUser),
    };
  } else if (userId && httpMethod === 'DELETE') {
    const deleteResult = await usersController.deleteUser(userId);
    return {
      statusCode: 200,
      body: JSON.stringify(deleteResult),
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

  try {
    validateSystemConfig();
    return await usersRouter(event);
  } catch (error) {
    return handleError(error)
  }
};
