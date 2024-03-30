import { APIUser, CreateUserParams, UpdateUserParams } from '../types/types';
import { UserService } from '../services/userService';

const usersService = new UserService();

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

  async updateUser(username: string, requestBody: UpdateUserParams): Promise<APIUser> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof UpdateUserParams> = [
      'email',
      'given_name',
      'family_name',
    ];
    const cleanedRequestBody: Partial<UpdateUserParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return await usersService.updateUser(username, cleanedRequestBody);
  }

  async deleteUser(username: string): Promise<string> {
    return await usersService.deleteUser(username);
  }
}
