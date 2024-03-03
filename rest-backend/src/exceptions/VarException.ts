export interface ErrorCase {
  code: number;
  message: string;
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

export class UserException extends VarException {
  constructor(errorCase: ErrorCase) {
    super(errorCase);
    this.name = 'VarException/User';
  }
}