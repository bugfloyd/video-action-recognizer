import FileModel, { IFile, IFileBase } from '../db/models/fileModel';
import { v4 as uuidv4 } from 'uuid';
import { VarException } from '../exceptions/VarException';
import { fileCases } from '../exceptions/cases/fileCases';
import { CreateVideoFileParams, VideoFile } from '../types/videoFile';
import { convertFileDBToVideoFile } from '../db/entityMappers';

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
}

const fileRepository = new FileRepository();
export default fileRepository;
