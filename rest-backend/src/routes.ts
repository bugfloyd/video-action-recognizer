import {
  createAnalysisRequestProps,
  createFileRequestProps,
  createUserProps,
  generateUploadSignedUrlRequestParams,
  updateAnalysisRequestProps,
  updateFileRequestProps,
  updateUserProps,
} from './allowedBodyParamas';
import { RouteDefinition } from './types/types';
import { getPathParam, getQueryParam, parseBody } from './utils';
import { UserService } from './services/userService';
import { FileService } from './services/fileService';
import { AnalysisService } from './services/analysisService';

const usersService = new UserService();
const fileService = new FileService();
const analysisService = new AnalysisService();

export const userRoutes: RouteDefinition = {
  '/users': {
    GET: () => usersService.getUsers(),
    POST: (_pathParams, body) =>
      usersService.postUser(parseBody(body, createUserProps)),
  },
  '/users/{userId}': {
    GET: (pathParams) =>
      usersService.getUser(getPathParam(pathParams, 'userId')),
    PATCH: (pathParams, body) =>
      usersService.updateUser(
        getPathParam(pathParams, 'userId'),
        parseBody(body, updateUserProps)
      ),
    DELETE: (pathParams) =>
      usersService.deleteUser(getPathParam(pathParams, 'userId')),
  },
};

export const fileRoutes: RouteDefinition = {
  '/files': {
    GET: () => fileService.getFiles(),
  },
  '/files/{userId}/generate-signed-url': {
    POST: (pathParams, body) =>
      fileService.generateUploadSignedUrl(
        getPathParam(pathParams, 'userId'),
        parseBody(body, generateUploadSignedUrlRequestParams)
      ),
  },
  '/files/{userId}': {
    POST: (pathParams, body) =>
      fileService.createFile(
        getPathParam(pathParams, 'userId'),
        parseBody(body, createFileRequestProps)
      ),
    GET: (pathParams) =>
      fileService.getUserFiles(getPathParam(pathParams, 'userId')),
  },
  '/files/{userId}/{fileId}': {
    GET: (pathParams, _body, queryStringParameters) =>
      fileService.getFile(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getQueryParam(queryStringParameters, 'signUrl')
      ),
    PATCH: (pathParams, body) =>
      fileService.updateFile(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        parseBody(body, updateFileRequestProps)
      ),
    DELETE: (pathParams) =>
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
    POST: (pathParams, body) =>
      analysisService.createAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        parseBody(body, createAnalysisRequestProps)
      ),
    GET: (pathParams) =>
      analysisService.getFileAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId')
      ),
  },
  '/analysis/{userId}/{fileId}/{analysisId}': {
    GET: (pathParams, _body, queryStringParameters) =>
      analysisService.getAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId'),
        getQueryParam(queryStringParameters, 'signUrl')
      ),
    PATCH: (pathParams, body) =>
      analysisService.updateAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId'),
        parseBody(body, updateAnalysisRequestProps)
      ),
    DELETE: (pathParams) =>
      analysisService.deleteAnalysis(
        getPathParam(pathParams, 'userId'),
        getPathParam(pathParams, 'fileId'),
        getPathParam(pathParams, 'analysisId')
      ),
  },
};
