export const globalCases = {
  unexpectedError: {
    code: 500,
    message: 'An unexpected error happened',
  },
  notImplemented: {
    code: 501,
    message: 'Not implemented',
  },
  invalidPathParams: {
    code: 400,
    message: 'Invalid path parameters provided.',
  },
  invalidBodyJson: {
    code: 400,
    message: 'Invalid JSON provided as the request body',
  },
  badConfig: {
    code: 500,
    message: 'Something went wrong. Please try again later.',
  },
} as const;