import { VarException } from '../exceptions/VarException';
import {
  CreateResultRequest,
  ResultAPI,
  UpdateResultRequest,
} from '../types/result';
import { resultCases } from '../exceptions/cases/resultCases';
import resultRepository from '../repositories/resultRepository';
import { validateUserId } from '../utils';

export class ResultService {
  async createResult(
    userId: string,
    fileId: string,
    params: Partial<CreateResultRequest>
  ): Promise<ResultAPI> {
    const { data } = params;

    if (!data || !data.model || !data.output) {
      throw new VarException(
        resultCases.createResult.createResultMissingParams
      );
    }

    const createResultParams: CreateResultRequest = {
      data,
    };

    return await resultRepository.createResult(
      userId,
      fileId,
      createResultParams
    );
  }

  async getResults(): Promise<ResultAPI[]> {
    return resultRepository.getAllResults();
  }

  async getFileResults(userId: string, fileId: string): Promise<ResultAPI[]> {
    if (!validateUserId(userId)) {
      throw new VarException(resultCases.getFileResults.InvalidUserId);
    }
    return resultRepository.getFileResults(userId, fileId);
  }

  async getResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<ResultAPI> {
    if (!validateUserId(userId)) {
      throw new VarException(resultCases.getResult.InvalidUserId);
    }
    return resultRepository.getResult(userId, fileId, resultId);
  }

  async updateResult(
    userId: string,
    fileId: string,
    resultId: string,
    params: Partial<UpdateResultRequest>
  ): Promise<ResultAPI> {
    const { data } = params;
    if ((data && !data.model) || !data?.output) {
      throw new VarException(
        resultCases.updateResult.updateResultMissingParams
      );
    }

    return await resultRepository.updateResult(
      userId,
      fileId,
      resultId,
      params
    );
  }

  async deleteResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<'deleted'> {
    await resultRepository.deleteResult(userId, fileId, resultId);
    return 'deleted';
  }
}
