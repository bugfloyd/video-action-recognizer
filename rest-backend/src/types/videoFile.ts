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
  userId: string;
  key: string;
  name: string;
  description?: string;
}
