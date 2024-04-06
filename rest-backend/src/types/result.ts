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

export interface CreateResultRequest {
  data: {
    model: string;
    output: object;
  };
}

export interface UpdateResultRequest {
  data?: {
    model: string;
    output: object;
  };
}
