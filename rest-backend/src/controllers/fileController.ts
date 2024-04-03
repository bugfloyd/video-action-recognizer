import { FileService } from '../services/fileService';
import {
  CreateVideoFileParams,
  GenerateSignedUrlParams,
  GenerateSignedUrlResponse,
  UpdateVideoFileParams,
  VideoFile,
} from '../types/videoFile';

const fileService = new FileService();

export class FileController {
  createFile(
    userId: string,
    requestBody: CreateVideoFileParams
  ): Promise<VideoFile> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof CreateVideoFileParams> = [
      'key',
      'name',
      'description',
    ];
    const cleanedRequestBody: Partial<CreateVideoFileParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return fileService.createFile(userId, cleanedRequestBody);
  }

  getFiles(): Promise<VideoFile[]> {
    return fileService.getFiles();
  }

  getUserFiles(userId: string): Promise<VideoFile[]> {
    return fileService.getUserFiles(userId);
  }

  getFile(userId: string, fileId: string): Promise<VideoFile> {
    return fileService.getFile(userId, fileId);
  }

  updateFile(
    userId: string,
    fileId: string,
    requestBody: UpdateVideoFileParams
  ): Promise<VideoFile> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof UpdateVideoFileParams> = [
      'name',
      'description',
    ];
    const cleanedRequestBody: Partial<UpdateVideoFileParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return fileService.updateFile(userId, fileId, cleanedRequestBody);
  }

  deleteFile(userId: string, fileId: string): Promise<'deleted'> {
    return fileService.deleteFile(userId, fileId);
  }

  generateUploadSignedUrl(
    userId: string,
    requestBody: GenerateSignedUrlParams
  ): Promise<GenerateSignedUrlResponse> {
    const validKeys: Array<keyof GenerateSignedUrlParams> = ['key'];
    const cleanedRequestBody: Partial<GenerateSignedUrlParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return fileService.generateSignedUrl(userId, cleanedRequestBody);
  }
}
