import { ErrorCases, VarException, ErrorCase } from './shared/exceptions';

export class UserException extends VarException {
  constructor(errorCase: ErrorCase) {
    super(errorCase);
    this.name = 'VarException/User';
  }
}

export const userCases: ErrorCases = {
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
};
