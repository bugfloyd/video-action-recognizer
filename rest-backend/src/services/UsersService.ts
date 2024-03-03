import {
  AdminCreateUserCommandOutput,
  ListUsersCommandOutput,
  UserType,
} from '@aws-sdk/client-cognito-identity-provider';
import { userCases } from '../exceptions/cases/userCases';
import { AWSCognito } from '../aws/AWSCognito';
import { APIUser, CreateUserParams } from '../types/types';
import { globalCases } from '../exceptions/cases/globalCases';
import { UserException } from '../exceptions/VarException';

const cognito = new AWSCognito();

function validateEmail(email: string): boolean {
  const regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
  return regex.test(email);
}

export class UsersService {
  async registerUser(params: Partial<CreateUserParams>): Promise<APIUser> {
    const { email, given_name, family_name } = params;

    if (!email || !given_name) {
      throw new UserException(userCases.createUser.createUserMissingParams);
    }

    if (!validateEmail(email)) {
      throw new UserException(userCases.createUser.invalidEmail);
    }

    let createUserResponse: AdminCreateUserCommandOutput;
    try {
      createUserResponse = await cognito.create({
        email,
        given_name,
        family_name,
      });
    } catch (error) {
      if (error instanceof Error) {
        if (error.name === 'UsernameExistsException') {
          throw new UserException(userCases.createUser.userExist);
        }
      }
      throw new UserException(globalCases.unexpectedError);
    }

    if (!createUserResponse || !createUserResponse.User) {
      throw new UserException(globalCases.unexpectedError);
    }
    const user = createUserResponse.User;

    const findUserAttribute = (user: UserType, name: string): string => {
      return user.Attributes?.find((attr) => attr.Name === name)?.Value || '';
    };

    return {
      username: user.Username ? user.Username : undefined,
      email: findUserAttribute(user, 'email'),
      given_name: findUserAttribute(user, 'given_name'),
      family_name: findUserAttribute(user, 'family_name'),
      created_at: user.UserCreateDate ? user.UserCreateDate : undefined,
      modified_at: user.UserLastModifiedDate
        ? user.UserLastModifiedDate
        : undefined,
    };
  }

  async getUsers(): Promise<APIUser[]> {
    let listUserResponse: ListUsersCommandOutput;
    try {
      listUserResponse = await cognito.list();
    } catch (error) {
      console.log("Error: ", error)
      throw new UserException(globalCases.unexpectedError);
    }

    const findUserAttribute = (user: UserType, name: string): string => {
      return user.Attributes?.find((attr) => attr.Name === name)?.Value || '';
    };

    return listUserResponse.Users?.map((user) => ({
      username: user.Username ? user.Username : undefined,
      email: findUserAttribute(user, 'email'),
      given_name: findUserAttribute(user, 'given_name'),
      family_name: findUserAttribute(user, 'family_name'),
      created_at: user.UserCreateDate ? user.UserCreateDate : undefined,
      modified_at: user.UserLastModifiedDate
        ? user.UserLastModifiedDate
        : undefined,
    })) || [];
  }
}
