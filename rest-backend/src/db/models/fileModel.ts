import dynamoose from 'dynamoose';
import { Item } from 'dynamoose/dist/Item';

export interface IFileBase {
  pk: string;
  sk: string;
  userId: string;
  fileId: string;
  key: string;
  name: string;
  description?: string;
  type: string;
}

interface EntityTimestamps {
  createdAt: string;
  updatedAt: string;
}
export interface IFile extends Item, IFileBase, EntityTimestamps {}

// File Model
const FileSchema = new dynamoose.Schema(
  {
    pk: {
      type: String,
      hashKey: true,
    },
    sk: {
      type: String,
      rangeKey: true,
    },
    userId: {
      type: String,
      required: true,
    },
    fileId: {
      type: String,
      required: true,
    },
    key: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: false,
    },
    type: {
      type: String,
      index: {
        name: 'TypeGSI',
        type: 'global',
      },
    },
  },
  {
    saveUnknown: false,
    timestamps: {
      createdAt: {
        createdAt: {
          type: Number,
          index: {
            name: 'DateLSI',
            type: 'local',
          },
        }
      },
      updatedAt: {
        updatedAt: {
          type: Number
        }
      }
    },
  }
);

const FileModel = dynamoose.model<IFile>('VarMain', FileSchema, {
  create: false,
});
export default FileModel;
