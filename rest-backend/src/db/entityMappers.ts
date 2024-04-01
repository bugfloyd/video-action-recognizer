import { IFile } from './models/fileModel';
import { VideoFile } from '../types/videoFile';
import { ResultAPI } from '../types/result';
import { IResult } from './models/resultModel';

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

export const convertResultDBToAPI = (result: IResult): ResultAPI => {
  return {
    id: result.resultId,
    userId: result.userId,
    fileId: result.fileId,
    data: {
      model: result.data.model,
      output: result.data.output,
    },
    createdAt: result.createdAt,
    updatedAt: result.updatedAt,
  };
};
