import FileModel, { IFile, IFileBase } from '../db/models/fileModel';
import { v4 as uuidv4 } from 'uuid';
import { VarException } from '../exceptions/VarException';
import { fileCases } from '../exceptions/cases/fileCases';
import {
  CreateVideoFileParams,
  UpdateVideoFileParams,
  VideoFile,
} from '../types/videoFile';
import { convertFileDBToVideoFile } from '../db/entityMappers';
import { QueryResponse } from 'dynamoose/dist/ItemRetriever';
import dynamoose from 'dynamoose';

class FileRepository {
  async createFile(userId: string, file: CreateVideoFileParams): Promise<VideoFile> {
    const { key, name, description } = file;
    const fileId = uuidv4();
    const createFileObj: IFileBase = {
      pk: `FILE#${userId}`,
      sk: fileId,
      userId,
      fileId,
      key,
      name,
      description,
      type: 'FILE',
    };

    let dbFile: IFile;
    try {
      dbFile = await FileModel.create(createFileObj);
    } catch (e) {
      throw new VarException(fileCases.createFile.FailedToCreateRef, e);
    }
    if (!dbFile || !dbFile.fileId) {
      throw new VarException(fileCases.createFile.FailedToCreateRef);
    }
    return convertFileDBToVideoFile(dbFile);
  }

  async getAllFiles(): Promise<VideoFile[]> {
    const dbFiles: IFile[] = [];
    try {
      const results: QueryResponse<IFile> = await FileModel.query('type')
        .eq('FILE')
        .using('TypeGSI')
        .all() // Fetch all records; be cautious with this in production for large datasets
        .exec();

      dbFiles.push(...results);
      return dbFiles.map((dbFile) => convertFileDBToVideoFile(dbFile));
    } catch (e) {
      throw new VarException(fileCases.getFiles.FailedToQueryFiles, e);
    }
  }

  async getFile(userId: string, fileId: string): Promise<VideoFile> {
    let dbFile: IFile;
    try {
      dbFile = await FileModel.get({ pk: `FILE#${userId}`, sk: fileId });
    } catch (e) {
      throw new VarException(fileCases.getFile.FailedToQueryFile, e);
    }
    if (!dbFile || !dbFile.fileId) {
      throw new VarException(fileCases.getFile.NotFound);
    }
    return convertFileDBToVideoFile(dbFile);
  }

  async updateFile(
    userId: string,
    fileId: string,
    updates: UpdateVideoFileParams
  ): Promise<VideoFile> {
    let updatedFile: IFile;
    try {
      const condition = new dynamoose.Condition().filter('fileId').exists();
      updatedFile = await FileModel.update(
        { pk: `FILE#${userId}`, sk: fileId },
        updates,
        { condition: condition }
      );
    } catch (e) {
      if ( e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(fileCases.updateFile.NotFound, e);
      }
      throw new VarException(fileCases.updateFile.FailedToUpdateFile, e);
    }
    if (!updatedFile || !updatedFile.fileId) {
      throw new VarException(fileCases.updateFile.NotFound);
    }
    return convertFileDBToVideoFile(updatedFile);
  }

  async deleteFile(userId: string, fileId: string): Promise<void> {
    try {
      const condition = new dynamoose.Condition().filter('fileId').exists();
      await FileModel.delete({ pk: `FILE#${userId}`, sk: fileId }, {condition: condition});
    } catch (e) {
      if ( e instanceof Error && e.name === 'ConditionalCheckFailedException') {
        throw new VarException(fileCases.deleteFile.NotFound, e);
      }
      throw new VarException(fileCases.deleteFile.FailedToDeleteFile, e);
    }
  }
}

const fileRepository = new FileRepository();
export default fileRepository;
