export const resultCases = {
  createResult: {
    createResultMissingParams: {
      code: 400,
      message: 'Model and output are required.',
    },
    FileNotFound: {
      code: 404,
      message: 'File not found.',
    },
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    InvalidFileId: {
      code: 400,
      message: 'The provided file ID is not valid or does not exist.',
    },
    InvalidModel: {
      code: 400,
      message: 'The provided model is not valid.',
    },
    InvalidData: {
      code: 400,
      message: 'The provided data is not valid.',
    },
    FailedToCreateRef: {
      code: 500,
      message: 'Failed to create the result reference.',
    },
  },
  getResults: {
    FailedToQueryResults: {
      code: 500,
      message: 'Failed to query results.',
    },
  },
  getUserResults: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    FailedToQueryResults: {
      code: 500,
      message: 'Failed to query results.',
    },
  },
  getFileResults: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    InvalidFileId: {
      code: 400,
      message: 'The provided file ID is not valid or does not exist.',
    },
    FailedToQueryResults: {
      code: 500,
      message: 'Failed to query results.',
    },
  },
  getResult: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    InvalidFileId: {
      code: 400,
      message: 'The provided file ID is not valid or does not exist.',
    },
    FailedToQueryResult: {
      code: 500,
      message: 'Failed to query result.',
    },
    NotFound: {
      code: 404,
      message: 'The requested result not found.',
    },
  },
  updateResult: {
    updateResultMissingParams: {
      code: 400,
      message: 'Model and output are required.',
    },
    FailedToUpdateResult: {
      code: 500,
      message: 'Failed to update the requested result.',
    },
    NotFound: {
      code: 404,
      message: 'The requested result not found.',
    },
  },
  deleteResult: {
    FailedToDeleteResult: {
      code: 500,
      message: 'Failed to delete the requested result.',
    },
    NotFound: {
      code: 404,
      message: 'The requested result not found.',
    },
  },
} as const;
