import { FileService } from '../services/fileService';
import { CreateVideoFileParams, UpdateVideoFileParams, VideoFile } from '../types/videoFile';

const fileService = new FileService();

export class FileController {
  async createFile(userId: string, requestBody: CreateVideoFileParams): Promise<VideoFile> {
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
    return await fileService.createFile(userId, cleanedRequestBody);
  }

  async getFiles(): Promise<VideoFile[]> {
    return await fileService.getFiles();
  }

  async getFile(userId: string, fileId: string): Promise<VideoFile> {
    return await fileService.getFile(userId, fileId);
  }

  async updateFile(userId: string, fileId: string, requestBody: UpdateVideoFileParams): Promise<VideoFile> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof UpdateVideoFileParams> = [
      'name',
      'description'
    ];
    const cleanedRequestBody: Partial<UpdateVideoFileParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return await fileService.updateFile(userId, fileId, cleanedRequestBody);
  }

  async deleteFile(userId: string, fileId: string): Promise<'deleted'> {
    return await fileService.deleteFile(userId, fileId);
  }
}
