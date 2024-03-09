import { APIUser, CreateUserParams } from '../types/types';
import { UsersService } from '../services/UsersService';

const usersService = new UsersService();

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

    return await usersService.registerUser(cleanedRequestBody);
  }

  async getUsers(): Promise<APIUser[]> {
    return await usersService.getUsers();
  }

  async getUser(username: string): Promise<APIUser> {
    return await usersService.getUser(username);
  }

  async deleteUser(username: string): Promise<string> {
    return await usersService.deleteUser(username);
  }
}
