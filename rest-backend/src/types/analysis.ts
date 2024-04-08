export interface AnalysisAPI {
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

export interface CreateAnalysisRequest {
  data: {
    model: string;
    output: object;
  };
}

export interface UpdateAnalysisRequest {
  data?: {
    model: string;
    output: object;
  };
}
