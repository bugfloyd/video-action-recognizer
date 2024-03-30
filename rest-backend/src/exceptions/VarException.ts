export interface ErrorCase {
  code: number;
  message: string;
}

export class VarException extends Error {
  code: number; // http error code
  originalError: unknown; // original error object

  constructor(errorCase: ErrorCase, originalError?: unknown) {
    const { message, code } = errorCase;
    super(message);
    this.code = code;
    this.name = 'VarException';
    this.originalError = originalError;
  }
}

export class UserException extends VarException {
  constructor(errorCase: ErrorCase, originalError?: unknown) {
    super(errorCase, originalError);
    this.name = 'VarException/User';
  }
}