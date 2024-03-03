export const userCases = {
  createUser: {
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
  },
  getUsers: {},
  getUser: {
    UserNotFound: {
      code: 404,
      message: 'No user account found using the provided username.',
    },
  },
} as const;
