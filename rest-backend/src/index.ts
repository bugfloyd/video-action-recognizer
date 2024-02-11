import { UserController } from './UsersController';
import { VarException, configCases, globalCases } from './shared/exceptions';
import { userPoolId } from './variables';
import { handlerFactory } from './shared/handlers';
import { UserException } from './UserExceptions';
import { ServiceRouter } from './shared/types';

const usersRouter: ServiceRouter = async (event) => {
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

const validateUsersLambdaConfig = () => {
  if (!userPoolId) {
    console.error('ERROR - No USER_POOL_ID environment variable found');
    throw new VarException(configCases.badConfig);
  }
};

export const handler = handlerFactory(usersRouter, validateUsersLambdaConfig);
