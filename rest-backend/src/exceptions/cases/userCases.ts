
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
  getUsers: {
    noUsersFound: {
      code: 409,
      message: 'There is no user',
    },
  },
} as const;