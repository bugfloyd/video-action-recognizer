import { ResultService } from '../services/resultService';
import {
  CreateResultParams,
  ResultAPI,
  UpdateResultParams,
} from '../types/result';

const resultService = new ResultService();

export class ResultController {
  async createResult(
    userId: string,
    fileId: string,
    requestBody: CreateResultParams
  ): Promise<ResultAPI> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof CreateResultParams> = ['data'];
    const cleanedRequestBody: Partial<CreateResultParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return await resultService.createResult(userId, fileId, cleanedRequestBody);
  }

  async getResults(): Promise<ResultAPI[]> {
    return await resultService.getResults();
  }

  async getFileResults(userId: string, fileId: string): Promise<ResultAPI[]> {
    return await resultService.getFileResults(userId, fileId);
  }

  async getResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<ResultAPI> {
    return await resultService.getResult(userId, fileId, resultId);
  }

  async updateResult(
    userId: string,
    fileId: string,
    resultId: string,
    requestBody: UpdateResultParams
  ): Promise<ResultAPI> {
    // Validate and clean up the requestBody
    const validKeys: Array<keyof UpdateResultParams> = ['data'];
    const cleanedRequestBody: Partial<UpdateResultParams> = {};
    for (const key of validKeys) {
      if (requestBody && requestBody[key]) {
        cleanedRequestBody[key] = requestBody[key];
      }
    }
    return await resultService.updateResult(
      userId,
      fileId,
      resultId,
      cleanedRequestBody
    );
  }

  async deleteResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<'deleted'> {
    return await resultService.deleteResult(userId, fileId, resultId);
  }
}
