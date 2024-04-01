import dynamoose from 'dynamoose';
import { Item } from 'dynamoose/dist/Item';
import { EntityTimestamps } from '../../types/types';

export interface IResultBase {
  pk: string;
  sk: string;
  userId: string;
  fileId: string;
  resultId: string;
  data: {
    model: string;
    output: object;
  };
  type: string;
}

export interface IResult extends Item, IResultBase, EntityTimestamps {}

// Define a nested schema for your object if needed
const resultDataSchema = new dynamoose.Schema({
  model: String,
  output: Object
}, {
  saveUnknown: true,
});

// File Model
const ResultSchema = new dynamoose.Schema(
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
    resultId: {
      type: String,
      required: true,
    },
    data: resultDataSchema,
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
        },
      },
      updatedAt: {
        updatedAt: {
          type: Number,
        },
      },
    },
  }
);

const ResultModel = dynamoose.model<IResult>('VarMain', ResultSchema, {
  create: false,
});
export default ResultModel;
