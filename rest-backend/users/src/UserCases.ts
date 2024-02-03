export class UserException extends Error {
  code: number; // http error code

  constructor(errorCase: UserCase) {
    const { message, code } = errorCase;
    super(message);
    this.code = code;
    this.name = 'UserException';
  }
}

interface UserCase {
  message: string;
  code: number;
}

export const UserCases = {
  invalidUserJson: {
    code: 400,
    message: 'Invalid user JSON provided',
  },
  createUserMissingParams: {
    code: 400,
    message: 'Email address and given name are required!',
  },
  invalidEmail: {
    code: 400,
    message: 'The provided email address is not valid!',
  },
  userExist: {
    code: 409,
    message: 'An account with the given email already exists.',
  },
  unexpextedError: {
    code: 500,
    message: 'While creating the user, an unexpected error happened',
  },
  notImplemented: {
    code: 501,
    message: 'Not implemented',
  },
};
