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

}

const fileRepository = new FileRepository();
export default fileRepository;
