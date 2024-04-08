import { IFile } from './models/fileModel';
import { VideoFile } from '../types/videoFile';
import { AnalysisAPI } from '../types/analysis';
import { IAnalysis } from './models/analysisModel';

export const convertFileDBToVideoFile = (file: IFile): VideoFile => {
  return {
    id: file.fileId,
    userId: file.userId,
    key: file.key,
    name: file.name,
    description: file.description,
    createdAt: file.createdAt,
    updatedAt: file.updatedAt,
  };
};

export const convertAnalysisDBToAPI = (analysis: IAnalysis): AnalysisAPI => {
  return {
    id: analysis.analysisId,
    userId: analysis.userId,
    fileId: analysis.fileId,
    data: {
      model: analysis.data.model,
      output: analysis.data.output,
    },
    createdAt: analysis.createdAt,
    updatedAt: analysis.updatedAt,
  };
};
