import FileModel, { IFile, IFileBase } from '../db/models/fileModel';
import { v4 as uuidv4 } from 'uuid';
import { VarException } from '../exceptions/VarException';
import { fileCases } from '../exceptions/cases/fileCases';
import { CreateVideoFileParams, VideoFile } from '../types/videoFile';
import { convertFileDBToVideoFile } from '../db/entityMappers';
import { QueryResponse } from 'dynamoose/dist/ItemRetriever';

class FileRepository {
  async createFile(file: CreateVideoFileParams): Promise<VideoFile> {
    const { userId, key, name, description } = file;
    const data = new Date().toISOString();
    const fileId = uuidv4();
    const createFileObj: IFileBase = {
      pk: `FILE#${userId}`,
      sk: `${data}#USER#${userId}#FILE#${fileId}`,
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

  async getFile(userId: string, fileId: string): Promise<VideoFile> {
    try {
      const dbFiles = await FileModel.query('pk')
        .eq(`FILE#${userId}`)
        .where('fileId')
        .eq(fileId)
        .limit(1)
        .exec();
      return convertFileDBToVideoFile(dbFiles[0]);
    } catch (e) {
      throw new VarException(fileCases.getFile.FailedToQueryFile, e);
    }
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
}

const fileRepository = new FileRepository();
export default fileRepository;
