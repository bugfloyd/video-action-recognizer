import { v4 as uuidv4 } from 'uuid';
import { VarException } from '../exceptions/VarException';
import { convertAnalysisDBToAPI } from '../db/entityMappers';
import { QueryResponse } from 'dynamoose/dist/ItemRetriever';
import dynamoose from 'dynamoose';
import {
  CreateAnalysisRequest,
  AnalysisAPI,
  UpdateAnalysisRequest,
} from '../types/analysis';
import AnalysisModel, { IAnalysis, IAnalysisBase } from '../db/models/analysisModel';
import { analysisCases } from '../exceptions/cases/analysisCases';

class AnalysisRepository {
  async createAnalysis(
    userId: string,
    fileId: string,
    analysis: CreateAnalysisRequest
  ): Promise<AnalysisAPI> {
    const { data } = analysis;
    const analysisId = uuidv4();
    const createAnalysisObj: IAnalysisBase = {
      pk: `ANALYSIS#${userId}#${fileId}`,
      sk: analysisId,
      userId,
      fileId,
      analysisId: analysisId,
      data: data,
      type: 'ANALYSIS',
    };

    let dbAnalysis: IAnalysis;
    try {
      dbAnalysis = await AnalysisModel.create(createAnalysisObj);
    } catch (e) {
      throw new VarException(analysisCases.createAnalysis.FailedToCreateRef, e);
    }
    if (!dbAnalysis || !dbAnalysis.analysisId) {
      throw new VarException(analysisCases.createAnalysis.FailedToCreateRef);
    }
    return convertAnalysisDBToAPI(dbAnalysis);
  }

  async getAllAnalysis(): Promise<AnalysisAPI[]> {
    const dbAnalysis: IAnalysis[] = [];
    try {
      const analysis: QueryResponse<IAnalysis> = await AnalysisModel.query('type')
        .eq('ANALYSIS')
        .using('TypeGSI')
        .sort('descending')
        .all() // Fetch all records; be cautious with this in production for large datasets
        .exec();

      dbAnalysis.push(...analysis);
      return dbAnalysis.map((dbAnalysis) => convertAnalysisDBToAPI(dbAnalysis));
    } catch (e) {
      throw new VarException(analysisCases.getAnalysis.FailedToQueryAnalysis, e);
    }
  }

  async getFileAnalysis(userId: string, fileId: string): Promise<AnalysisAPI[]> {
    const dbAnalysis: IAnalysis[] = [];
    try {
      const analysis: QueryResponse<IAnalysis> = await AnalysisModel.query('pk')
        .eq(`ANALYSIS#${userId}#${fileId}`)
        .using('DateLSI')
        .sort('descending')
        .all()
        .exec();
      dbAnalysis.push(...analysis);
      return dbAnalysis.map((dbAnalysis) => convertAnalysisDBToAPI(dbAnalysis));
    } catch (e) {
      throw new VarException(
        analysisCases.getUserAnalysis.FailedToQueryAnalysis,
        e
      );
    }
  }

  async getAnalysis(
    userId: string,
    fileId: string,
    analysisId: string
  ): Promise<AnalysisAPI> {
    let dbAnalysis: IAnalysis;
    try {
      dbAnalysis = await AnalysisModel.get({
        pk: `ANALYSIS#${userId}#${fileId}`,
        sk: analysisId,
      });
    } catch (e) {
      throw new VarException(analysisCases.getAnalysis.FailedToQueryAnalysis, e);
    }
    if (!dbAnalysis || !dbAnalysis.analysisId) {
      throw new VarException(analysisCases.getAnalysis.NotFound);
    }
    return convertAnalysisDBToAPI(dbAnalysis);
  }

  async updateAnalysis(
    userId: string,
    fileId: string,
    analysisId: string,
    updates: UpdateAnalysisRequest
  ): Promise<AnalysisAPI> {
    let updatedAnalysis: IAnalysis;
    try {
      const condition = new dynamoose.Condition().filter('analysisId').exists();
      updatedAnalysis = await AnalysisModel.update(
        { pk: `ANALYSIS#${userId}#${fileId}`, sk: analysisId },
        updates,
        { condition: condition }
      );
    } catch (e) {
      if (e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(analysisCases.updateAnalysis.NotFound, e);
      }
      throw new VarException(analysisCases.updateAnalysis.FailedToUpdateAnalysis, e);
    }
    if (!updatedAnalysis || !updatedAnalysis.fileId) {
      throw new VarException(analysisCases.updateAnalysis.NotFound);
    }
    return convertAnalysisDBToAPI(updatedAnalysis);
  }

  async deleteAnalysis(
    userId: string,
    fileId: string,
    analysisId: string
  ): Promise<void> {
    try {
      const condition = new dynamoose.Condition().filter('analysisId').exists();
      await AnalysisModel.delete(
        { pk: `ANALYSIS#${userId}#${fileId}`, sk: analysisId },
        { condition: condition }
      );
    } catch (e) {
      if (e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(analysisCases.deleteAnalysis.NotFound, e);
      }
      throw new VarException(analysisCases.deleteAnalysis.FailedToDeleteAnalysis, e);
    }
  }
}

const analysisRepository = new AnalysisRepository();
export default analysisRepository;
