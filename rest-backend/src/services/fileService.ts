import { VarException } from '../exceptions/VarException';
import {
  CreateVideoFileParams,
  UpdateVideoFileParams,
  VideoFile,
} from '../types/videoFile';
import { fileCases } from '../exceptions/cases/fileCases';
import { isUUID4 } from '../utils';
import fileRepository from '../repositories/fileRepository';

const validateUserId = (userId: string): boolean => {
  if (!userId || !isUUID4(userId)) {
    return false;
  }
  // ToDo: Check user existence
  return true;
};

const validateVideoKey = (key: string): boolean => {
  // ToDo: Check file existence
  return (
    !!key &&
    !key.startsWith('/') &&
    !key.endsWith('/') &&
    (key.endsWith('.mp4') || key.endsWith('.gif'))
  );
};

const validateName = (name: string): boolean => {
  return !!name;
};

export class FileService {
  async createFile(params: Partial<CreateVideoFileParams>): Promise<VideoFile> {
    const { userId, key, name, description } = params;

    if (!userId || !key || !name) {
      throw new VarException(fileCases.createFile.createFileMissingParams);
    }

    if (!validateUserId(userId)) {
      throw new VarException(fileCases.createFile.InvalidUserId);
    }

    if (!validateVideoKey(key)) {
      throw new VarException(fileCases.createFile.InvalidKey);
    }

    if (!validateName(name)) {
      throw new VarException(fileCases.createFile.InvalidName);
    }

    const createFileParams: CreateVideoFileParams = {
      userId,
      key,
      name,
      description,
    };

    return await fileRepository.createFile(createFileParams);
  }

  async getFiles(): Promise<VideoFile[]> {
    return fileRepository.getAllFiles();
  }

  async getFile(userId: string, fileId: string): Promise<VideoFile> {
    return fileRepository.getFile(userId, fileId);
  }

  async updateFile(
    userId: string,
    fileId: string,
    params: Partial<UpdateVideoFileParams>
  ): Promise<VideoFile> {
    const { name } = params;
    if (name && !validateName(name)) {
      throw new VarException(fileCases.createFile.InvalidName);
    }

    return await fileRepository.updateFile(userId, fileId, params);
  }

  async deleteFile(userId: string, fileId: string): Promise<'deleted'> {
    await fileRepository.deleteFile(userId, fileId);
    return 'deleted';
  }
}
