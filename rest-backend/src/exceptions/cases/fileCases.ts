export const fileCases = {
  createFile: {
    createFileMissingParams: {
      code: 400,
      message: 'User ID, key, and name are required!',
    },
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
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
  getFiles: {
    FailedToQueryFiles: {
      code: 500,
      message: 'Failed to query files.',
    },
  },
  getUserFiles: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    FailedToQueryFiles: {
      code: 500,
      message: 'Failed to query files.',
    },
  },
  getFile: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    FailedToQueryFile: {
      code: 500,
      message: 'Failed to query file.',
    },
    NotFound: {
      code: 404,
      message: 'The requested file not found.',
    },
  },
  updateFile: {
    InvalidName: {
      code: 400,
      message: 'The provided name is not valid!',
    },
    FailedToUpdateFile: {
      code: 500,
      message: 'Failed to update the requested file.',
    },
    NotFound: {
      code: 404,
      message: 'The requested file not found.',
    },
  },
  deleteFile: {
    FailedToDeleteFile: {
      code: 500,
      message: 'Failed to delete the requested file.',
    },
    NotFound: {
      code: 404,
      message: 'The requested file not found.',
    },
  },
  generateSignedUrl: {
    InvalidKey: {
      code: 400,
      message: 'The provided key is not valid!',
    },
    FailedToGenerateUrl: {
      code: 500,
      message: 'Failed to generate the requested signed URL.',
    },
  },
} as const;
