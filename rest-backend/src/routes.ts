import {
  createAnalysisRequestProps,
  createFileRequestProps,
  createUserProps,
  generateUploadSignedUrlRequestParams, updateAnalysisRequestProps, updateFileRequestProps,
  updateUserProps,
} from './allowedBodyParamas';
import { RouteDefinition } from './types/types';
import { getPathParam, parseBody } from './utils';
import { UserService } from './services/userService';
import { FileService } from './services/fileService';
import { AnalysisService } from './services/analysisService';

const usersService = new UserService();
const fileService = new FileService();
const analysisService = new AnalysisService();

export const userRoutes: RouteDefinition = {
  '/users': {
    GET: () => usersService.getUsers(),
    POST: (body) => usersService.registerUser(parseBody(body, createUserProps)),
  },
  '/users/{userId}': {
    GET: (_body, pathParams) =>
      usersService.getUser(getPathParam(pathParams, 'userId')),
    PATCH: (body, pathParams) =>
      usersService.updateUser(
        getPathParam(pathParams, 'userId'),
        parseBody(body, updateUserProps)
      ),
    DELETE: (_body, pathParams) =>
      usersService.deleteUser(getPathParam(pathParams, 'userId')),
  },
};
export const fileRoutes: RouteDefinition = {
  '/files': {
    GET: () => fileService.getFiles(),
  },
  '/files/{userId}/generate-signed-url': {
    POST: (body, pathParams) =>
      fileService.generateSignedUrl(
        getPathParam(pathParams, 'userId'),
        parseBody(body, generateUploadSignedUrlRequestParams)
      ),
  },
  '/files/{userId}': {
    POST: (body, pathParams) =>
      fileService.createFile(
        getPathParam(pathParams, 'userId'),
        parseBody(body, createFileRequestProps)
      ),
    GET: (_body, pathParams) =>
      fileService.getUserFiles(getPathParam(pathParams, 'userId')),
  },
  '/files/{userId}/{fileId}': {
    GET: (_body, pathParams) =>
      fileService.getFile(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId')
      ),
    PATCH: (body, pathParams) =>
      fileService.updateFile(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        parseBody(body, updateFileRequestProps)
      ),
    DELETE: (_body, pathParams) =>
      fileService.deleteFile(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId')
      ),
  },
};

export const analysisRoutes: RouteDefinition = {
  '/analysis': {
    GET: () => analysisService.getAllAnalysis(),
  },
  '/analysis/{userId}/{fileId}': {
    POST: (body, pathParams) =>
      analysisService.createAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        parseBody(body, createAnalysisRequestProps)
      ),
    GET: (_body, pathParams) =>
      analysisService.getFileAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId')
      ),
  },
  '/analysis/{userId}/{fileId}/{analysisId}': {
    GET: (_body, pathParams) =>
      analysisService.getAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId')
      ),
    PATCH: (body, pathParams) =>
      analysisService.updateAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId'),
        parseBody(body, updateAnalysisRequestProps)
      ),
    DELETE: (_body, pathParams) =>
      analysisService.deleteAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId')
      ),
  },
};