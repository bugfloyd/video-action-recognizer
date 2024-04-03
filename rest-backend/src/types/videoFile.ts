export interface VideoFile {
  id: string;
  userId: string;
  key: string;
  name: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateVideoFileParams {
  key: string;
  name: string;
  description?: string;
}

export interface UpdateVideoFileParams {
  name?: string;
  description?: string;
}

export interface GenerateSignedUrlParams {
  key: string;
}

export interface GenerateSignedUrlResponse {
  url: string;
  expiration: number;
}