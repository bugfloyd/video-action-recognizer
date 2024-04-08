import dynamoose from 'dynamoose';
import { Item } from 'dynamoose/dist/Item';
import { EntityTimestamps } from '../../types/types';

export interface IAnalysisBase {
  pk: string;
  sk: string;
  userId: string;
  fileId: string;
  analysisId: string;
  data: {
    model: string;
    output: object;
  };
  type: string;
}

export interface IAnalysis extends Item, IAnalysisBase, EntityTimestamps {}

// Define a nested schema for your object if needed
const analysisDataSchema = new dynamoose.Schema({
  model: String,
  output: Object
}, {
  saveUnknown: true,
});

// File Model
const AnalysisSchema = new dynamoose.Schema(
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
    analysisId: {
      type: String,
      required: true,
    },
    data: analysisDataSchema,
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

const AnalysisModel = dynamoose.model<IAnalysis>('VarMain', AnalysisSchema, {
  create: false,
});
export default AnalysisModel;
