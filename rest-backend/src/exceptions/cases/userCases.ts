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
    InvalidUsername: {
      code: 400,
      message: 'Invalid username provided'
    }
  },
  updateUser: {
    InvalidUsername: {
      code: 400,
      message: 'Invalid username provided'
    },
    MissingParams: {
      code: 400,
      message: 'One of email or name fields are required.',
    },
    InvalidEmail: {
      code: 400,
      message: 'The provided email address is not valid!',
    },
    UserNotFound: {
      code: 404,
      message: 'No user account found using the provided username.',
    },
    EmailExists: {
      code: 409,
      message: 'There is another user with the provided email address.',
    },
  },
  deleteUser: {
    UserNotFound: {
      code: 404,
      message: 'No user account found using the provided username.',
    },
    InvalidUsername: {
      code: 400,
      message: 'Invalid username provided'
    }
  },

} as const;
