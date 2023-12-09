import {
  AdminCreateUserCommand,
  CognitoIdentityProviderClient,
} from '@aws-sdk/client-cognito-identity-provider';
import {
  APIGatewayProxyEvent,
  APIGatewayProxyHandler,
  APIGatewayProxyResult,
} from 'aws-lambda';

interface UserInput {
  given_name: string;
  family_name?: string;
  email: string;
}

function validateEmail(email: string): boolean {
  const regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
  return regex.test(email);
}

async function createUserInCognito(userInput: UserInput, userPoolId: string) {
  const awsRegion: string = process.env.REGION || 'eu-central-1';
  const client = new CognitoIdentityProviderClient({ region: awsRegion });

  const command = new AdminCreateUserCommand({
    UserPoolId: userPoolId,
    Username: userInput.email,
    UserAttributes: [
      { Name: 'email', Value: userInput.email },
      { Name: 'given_name', Value: userInput.given_name },
      { Name: 'family_name', Value: userInput.family_name || '' },
    ],
    MessageAction: 'SUPPRESS',
  });

  try {
    const response = await client.send(command);
    console.log('User created:', response);
    return response;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}

export const handler: APIGatewayProxyHandler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const userpoolId: string = process.env.USER_POOL_ID || '';
  if (!userpoolId) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Unexpected error occured!',
      }),
    };
  }

  const httpMethod = event.httpMethod;
  const pathParameters = event.pathParameters;
  const userId = pathParameters ? pathParameters['user_id'] : null;

  let requestBody: UserInput;
  try {
    requestBody = event.body ? JSON.parse(event.body) : {};
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Invalid user JSON provided!',
      }),
    };
  }

  // Create a new User
  if (!userId && httpMethod === 'POST') {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof UserInput> = [
      'given_name',
      'family_name',
      'email',
    ];
    const cleanedRequestBody: Partial<UserInput> = {};
    for (const key of validKeys) {
      if (requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }

    if (!cleanedRequestBody.email || !cleanedRequestBody.given_name) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: 'Email address and given name are required!',
        }),
      };
    }

    if (!validateEmail(cleanedRequestBody.email)) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: 'The provided email address is not valid!',
        }),
      };
    }

    const userToCreate: UserInput = {
      given_name: cleanedRequestBody.given_name,
      family_name: cleanedRequestBody.family_name,
      email: cleanedRequestBody.email,
    };
    // Create Cognito user
    try {
      const createdUser = await createUserInCognito(userToCreate, userpoolId);

      return {
        statusCode: 200,
        body: JSON.stringify({
          message: 'User created successfully',
          user: {
            username: createdUser.User?.Username,
            email:
              createdUser.User?.Attributes?.find(
                (attr) => attr.Name === 'email'
              )?.Value || '',
            given_name:
              createdUser.User?.Attributes?.find(
                (attr) => attr.Name === 'given_name'
              )?.Value || '',
            family_name:
              createdUser.User?.Attributes?.find(
                (attr) => attr.Name === 'family_name'
              )?.Value || '',
            created_at: createdUser.User?.UserCreateDate,
            modified_at: createdUser.User?.UserLastModifiedDate,
          },
        }),
      };
    } catch (error) {
      return {
        statusCode: 500,
        body: JSON.stringify({
          message: 'Unexpected error occured!',
        }),
      };
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Request processed successfully',
      method: httpMethod,
      body: requestBody,
      userId,
    }),
  };
};
