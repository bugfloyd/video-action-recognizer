import { APIGatewayProxyEvent } from 'aws-lambda';
import { APIUser, CreateUserParams } from './types';
import { UsersService } from './UsersService';
import { UserCases, UserException } from './UserCases';

export class UserController {
  async createUser(event: APIGatewayProxyEvent): Promise<APIUser> {
    let requestBody: CreateUserParams;
    try {
      requestBody = event.body ? JSON.parse(event.body) : {};
    } catch (error) {
      console.error(error);
      throw new UserException(UserCases.invalidUserJson);
    }

    // Validate and clean up the requestBody
    const validKeys: Array<keyof CreateUserParams> = [
      'given_name',
      'family_name',
      'email',
    ];
    const cleanedRequestBody: Partial<CreateUserParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }

    const usersService = new UsersService();
    const response = await usersService.registerUser(cleanedRequestBody);
    return response;
  }
}
