import { VarException } from '../exceptions/VarException';
import {
  CreateAnalysisRequest,
  AnalysisAPI,
  UpdateAnalysisRequest,
} from '../types/analysis';
import { analysisCases } from '../exceptions/cases/analysisCases';
import analysisRepository from '../repositories/analysisRepository';
import { validateUserId } from '../utils';
import fileRepository from '../repositories/fileRepository';
import { putEvent } from '../aws/events';
import { eventTypes } from '../events';
import { VideoFile } from '../types/videoFile';
import { APIUser } from '../types/user';
import { UserService } from './userService';

const usersService = new UserService();

export class AnalysisService {
  async createAnalysis(
    userId: string,
    fileId: string,
    params: Partial<CreateAnalysisRequest>
  ): Promise<AnalysisAPI> {
    const { data } = params;

    if (!data || !data.model || !data.output) {
      throw new VarException(
        analysisCases.createAnalysis.createAnalysisMissingParams
      );
    }

    let user: APIUser;
    try {
      user = await usersService.getUser(userId);
    } catch (e) {
      throw new VarException(analysisCases.createAnalysis.UserNotFound);
    }

    let file: VideoFile;
    try {
      file = await fileRepository.getFile(userId, fileId);
    } catch (e) {
      throw new VarException(analysisCases.createAnalysis.FileNotFound);
    }

    const createAnalysisParams: CreateAnalysisRequest = {
      data,
    };

    const createdAnalysis = await analysisRepository.createAnalysis(
      userId,
      fileId,
      createAnalysisParams
    );

    const putEventResponse = await putEvent(eventTypes.ANALYSIS_REF_CREATED, {
      user: user,
      file: file,
      analysis: createdAnalysis,
    });
    console.log(
      `Event created: ${eventTypes.ANALYSIS_REF_CREATED}`,
      putEventResponse
    );
    return createdAnalysis;
  }

  async getAllAnalysis(): Promise<AnalysisAPI[]> {
    return analysisRepository.getAllAnalysis();
  }

  async getFileAnalysis(userId: string, fileId: string): Promise<AnalysisAPI[]> {
    if (!validateUserId(userId)) {
      throw new VarException(analysisCases.getFileAnalysis.InvalidUserId);
    }
    return analysisRepository.getFileAnalysis(userId, fileId);
  }

  async getAnalysis(
    userId: string,
    fileId: string,
    analysisId: string
  ): Promise<AnalysisAPI> {
    if (!validateUserId(userId)) {
      throw new VarException(analysisCases.getAnalysis.InvalidUserId);
    }
    return analysisRepository.getAnalysis(userId, fileId, analysisId);
  }

  async updateAnalysis(
    userId: string,
    fileId: string,
    analysisId: string,
    params: Partial<UpdateAnalysisRequest>
  ): Promise<AnalysisAPI> {
    const { data } = params;
    if (!data?.model || !data?.output) {
      throw new VarException(
        analysisCases.updateAnalysis.updateAnalysisMissingParams
      );
    }

    return await analysisRepository.updateAnalysis(
      userId,
      fileId,
      analysisId,
      params
    );
  }

  async deleteAnalysis(
    userId: string,
    fileId: string,
    analysisId: string
  ): Promise<'deleted'> {
    await analysisRepository.deleteAnalysis(userId, fileId, analysisId);
    return 'deleted';
  }
}
