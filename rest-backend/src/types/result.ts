export interface ResultAPI {
  id: string;
  userId: string;
  fileId: string;
  data: {
    model: string;
    output: object;
  };
  createdAt: string;
  updatedAt: string;
}

export interface CreateResultParams {
  data: {
    model: string;
    output: object;
  };
}

export interface UpdateResultParams {
  data?: {
    model: string;
    output: object;
  };
}
