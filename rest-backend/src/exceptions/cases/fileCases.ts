export const fileCases = {
  createFile: {
    createFileMissingParams: {
      code: 400,
      message: 'User ID, key, and name are required!',
    },
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid!',
    },
    InvalidKey: {
      code: 400,
      message: 'The provided key is not valid!',
    },
    InvalidName: {
      code: 400,
      message: 'The provided name is not valid!',
    },
    FailedToCreateRef: {
      code: 500,
      message: 'Failed to create the file reference.',
    },
  },
} as const;