import {
  AdminCreateUserCommandOutput,
  UserType,
} from '@aws-sdk/client-cognito-identity-provider';
import { userCases, UserException } from './UserExceptions';
import { AWSCognito } from './aws/AWSCognito';
import { CreateUserParams, APIUser } from './types';

function validateEmail(email: string): boolean {
  const regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
  return regex.test(email);
}

export class UsersService {
  async registerUser(params: Partial<CreateUserParams>): Promise<APIUser> {
    const { email, given_name, family_name } = params;

    if (!email || !given_name) {
      throw new UserException(userCases.createUserMissingParams);
    }

    if (!validateEmail(email)) {
      throw new UserException(userCases.invalidEmail);
    }

    const cognito = new AWSCognito();
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
          throw new UserException(userCases.userExist);
        }
      }
      throw new UserException(userCases.unexpextedError);
    }

    if (!createUserResponse || !createUserResponse.User) {
      throw new UserException(userCases.unexpextedError);
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
}
