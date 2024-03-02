import { APIUser, CreateUserParams } from './types';
import { UsersService } from './UsersService';

export class UserController {
  async createUser(requestBody: CreateUserParams): Promise<APIUser> {
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
    return await usersService.registerUser(cleanedRequestBody);
  }

  async getUsers(): Promise<APIUser[]> {
    const usersService = new UsersService();
    return await usersService.getUsers();
  }
}
