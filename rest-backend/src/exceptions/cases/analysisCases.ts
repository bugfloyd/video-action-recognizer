export const analysisCases = {
  createAnalysis: {
    createAnalysisMissingParams: {
      code: 400,
      message: 'Model and output are required.',
    },
    UserNotFound: {
      code: 404,
      message: 'User not found.',
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
      message: 'Failed to create the analysis reference.',
    },
  },
  getAnalysisList: {
    FailedToQueryAnalysis: {
      code: 500,
      message: 'Failed to query analysis.',
    },
  },
  getUserAnalysis: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    FailedToQueryAnalysis: {
      code: 500,
      message: 'Failed to query analysis.',
    },
  },
  getFileAnalysis: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    InvalidFileId: {
      code: 400,
      message: 'The provided file ID is not valid or does not exist.',
    },
    FailedToQueryAnalysis: {
      code: 500,
      message: 'Failed to query analysis.',
    },
  },
  getAnalysis: {
    InvalidUserId: {
      code: 400,
      message: 'The provided user ID is not valid or does not exist.',
    },
    InvalidFileId: {
      code: 400,
      message: 'The provided file ID is not valid or does not exist.',
    },
    FailedToQueryAnalysis: {
      code: 500,
      message: 'Failed to query analysis.',
    },
    NotFound: {
      code: 404,
      message: 'The requested analysis not found.',
    },
    FailedToGenerateUrl: {
      code: 500,
      message: 'Failed to generate the requested signed URL.',
    },
  },
  updateAnalysis: {
    updateAnalysisMissingParams: {
      code: 400,
      message: 'Model and output are required.',
    },
    FailedToUpdateAnalysis: {
      code: 500,
      message: 'Failed to update the requested analysis.',
    },
    NotFound: {
      code: 404,
      message: 'The requested analysis not found.',
    },
  },
  deleteAnalysis: {
    FailedToDeleteAnalysis: {
      code: 500,
      message: 'Failed to delete the requested analysis.',
    },
    NotFound: {
      code: 404,
      message: 'The requested analysis not found.',
    },
  },
} as const;
