import { CreateUserRequest, UpdateUserRequest } from './types/user';
import { CreateResultRequest, UpdateResultRequest } from './types/result';
import { CreateVideoFileRequest, GenerateUploadSignedUrlRequest, UpdateVideoFileRequest } from './types/videoFile';

export const createUserProps: Array<keyof CreateUserRequest> = [
  'email',
  'given_name',
  'family_name',
];

export const updateUserProps: Array<keyof UpdateUserRequest> = [
  'email',
  'given_name',
  'family_name',
];

export const createFileRequestProps: Array<keyof CreateVideoFileRequest> = [
  'key',
  'name',
  'description',
];

export const updateFileRequestProps: Array<keyof UpdateVideoFileRequest> = [
  'name',
  'description',
];

export const generateUploadSignedUrlRequestParams: Array<
  keyof GenerateUploadSignedUrlRequest
> = ['key'];

export const createResultRequestProps: Array<keyof CreateResultRequest> = [
  'data',
];

export const updateResultRequestProps: Array<keyof UpdateResultRequest> = [
  'data',
];