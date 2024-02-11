export interface ErrorCase {
  message: string;
  code: number;
}

export interface ErrorCases {
  [eventName: string]: {
    code: number;
    message: string;
  };
}

export class VarException extends Error {
  code: number; // http error code

  constructor(errorCase: ErrorCase) {
    const { message, code } = errorCase;
    super(message);
    this.code = code;
    this.name = 'VarException';
  }
}

export class ConfigException extends VarException {
  constructor(errorCase: ErrorCase) {
    super(errorCase);
    this.name = 'VarException/Config';
  }
}

export const globalCases: ErrorCases = {
  notImplemented: {
    code: 501,
    message: 'Not implemented',
  },
  invalidBodyJson: {
    code: 400,
    message: 'Invalid JSON provided as the request body',
  },
};

export const configCases: ErrorCases = {
  badConfig: {
    code: 500,
    message: 'Something went wrong. Please try again later.',
  },
};
