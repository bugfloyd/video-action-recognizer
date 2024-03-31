import { IFile } from './models/fileModel';
import { VideoFile } from '../types/videoFile';

export const convertFileDBToVideoFile = (file: IFile): VideoFile => {
  return {
    id: file.fileId,
    userId: file.userId,
    key: file.key,
    name: file.name,
    description: file.description,
    createdAt: file.createdAt,
    updatedAt: file.updatedAt,
  };
};