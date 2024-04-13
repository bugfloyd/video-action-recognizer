import { GenerateSignedUrlResponse } from './types';

export interface AnalysisOutput {
  output_file_path?: string;
  predictions?: Array<string | number>[];
  signedUrl?: GenerateSignedUrlResponse;
}

export interface AnalysisAPI {
  id: string;
  userId: string;
  fileId: string;
  data: {
    model: string;
    output: AnalysisOutput;
  };
  createdAt: string;
  updatedAt: string;
}

export interface CreateAnalysisRequest {
  data: {
    model: string;
    output: AnalysisOutput;
  };
}

export interface UpdateAnalysisRequest {
  data?: {
    model: string;
    output: AnalysisOutput;
  };
}
