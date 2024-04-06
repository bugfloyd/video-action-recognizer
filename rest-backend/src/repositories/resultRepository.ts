import { v4 as uuidv4 } from 'uuid';
import { VarException } from '../exceptions/VarException';
import { convertResultDBToAPI } from '../db/entityMappers';
import { QueryResponse } from 'dynamoose/dist/ItemRetriever';
import dynamoose from 'dynamoose';
import {
  CreateResultRequest,
  ResultAPI,
  UpdateResultRequest,
} from '../types/result';
import ResultModel, { IResult, IResultBase } from '../db/models/resultModel';
import { resultCases } from '../exceptions/cases/resultCases';

class ResultRepository {
  async createResult(
    userId: string,
    fileId: string,
    result: CreateResultRequest
  ): Promise<ResultAPI> {
    const { data } = result;
    const resultId = uuidv4();
    const createResultObj: IResultBase = {
      pk: `RESULT#${userId}#${fileId}`,
      sk: resultId,
      userId,
      fileId,
      resultId,
      data: data,
      type: 'RESULT',
    };

    let dbResult: IResult;
    try {
      dbResult = await ResultModel.create(createResultObj);
    } catch (e) {
      throw new VarException(resultCases.createResult.FailedToCreateRef, e);
    }
    if (!dbResult || !dbResult.resultId) {
      throw new VarException(resultCases.createResult.FailedToCreateRef);
    }
    return convertResultDBToAPI(dbResult);
  }

  async getAllResults(): Promise<ResultAPI[]> {
    const dbResults: IResult[] = [];
    try {
      const results: QueryResponse<IResult> = await ResultModel.query('type')
        .eq('RESULT')
        .using('TypeGSI')
        .sort('descending')
        .all() // Fetch all records; be cautious with this in production for large datasets
        .exec();

      dbResults.push(...results);
      return dbResults.map((dbResult) => convertResultDBToAPI(dbResult));
    } catch (e) {
      throw new VarException(resultCases.getResults.FailedToQueryResults, e);
    }
  }

  async getFileResults(userId: string, fileId: string): Promise<ResultAPI[]> {
    const dbResults: IResult[] = [];
    try {
      const results: QueryResponse<IResult> = await ResultModel.query('pk')
        .eq(`RESULT#${userId}#${fileId}`)
        .using('DateLSI')
        .sort('descending')
        .all()
        .exec();
      dbResults.push(...results);
      return dbResults.map((dbResult) => convertResultDBToAPI(dbResult));
    } catch (e) {
      throw new VarException(
        resultCases.getUserResults.FailedToQueryResults,
        e
      );
    }
  }

  async getResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<ResultAPI> {
    let dbResult: IResult;
    try {
      dbResult = await ResultModel.get({
        pk: `RESULT#${userId}#${fileId}`,
        sk: resultId,
      });
    } catch (e) {
      throw new VarException(resultCases.getResult.FailedToQueryResult, e);
    }
    if (!dbResult || !dbResult.resultId) {
      throw new VarException(resultCases.getResult.NotFound);
    }
    return convertResultDBToAPI(dbResult);
  }

  async updateResult(
    userId: string,
    fileId: string,
    resultId: string,
    updates: UpdateResultRequest
  ): Promise<ResultAPI> {
    let updatedResult: IResult;
    try {
      const condition = new dynamoose.Condition().filter('resultId').exists();
      updatedResult = await ResultModel.update(
        { pk: `RESULT#${userId}#${fileId}`, sk: resultId },
        updates,
        { condition: condition }
      );
    } catch (e) {
      if (e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(resultCases.updateResult.NotFound, e);
      }
      throw new VarException(resultCases.updateResult.FailedToUpdateResult, e);
    }
    if (!updatedResult || !updatedResult.fileId) {
      throw new VarException(resultCases.updateResult.NotFound);
    }
    return convertResultDBToAPI(updatedResult);
  }

  async deleteResult(
    userId: string,
    fileId: string,
    resultId: string
  ): Promise<void> {
    try {
      const condition = new dynamoose.Condition().filter('resultId').exists();
      await ResultModel.delete(
        { pk: `RESULT#${userId}#${fileId}`, sk: resultId },
        { condition: condition }
      );
    } catch (e) {
      if (e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(resultCases.deleteResult.NotFound, e);
      }
      throw new VarException(resultCases.deleteResult.FailedToDeleteResult, e);
    }
  }
}

const resultRepository = new ResultRepository();
export default resultRepository;
