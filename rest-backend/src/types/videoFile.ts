export interface VideoFile {
  id: string;
  userId: string;
  key: string;
  name: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateVideoFileRequest {
  key: string;
  name: string;
  description?: string;
}

export interface UpdateVideoFileRequest {
  name?: string;
  description?: string;
}

export interface GenerateUploadSignedUrlRequest {
  key: string;
}

export interface GenerateUploadSignedUrlResponse {
  url: string;
  expiration: number;
}
