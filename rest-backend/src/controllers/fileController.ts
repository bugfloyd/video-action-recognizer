import { FileService } from '../services/fileService';
import { CreateVideoFileParams, VideoFile } from '../types/videoFile';

const fileService = new FileService();

export class FileController {
  async createFile(requestBody: CreateVideoFileParams): Promise<VideoFile> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof CreateVideoFileParams> = [
      'userId',
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
    return await fileService.createFile(cleanedRequestBody);
  }
}
