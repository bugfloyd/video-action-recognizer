import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from '@aws-sdk/client-secrets-manager';
import { getSignedUrl } from '@aws-sdk/cloudfront-signer';
import {
  awsRegion,
  cloudfrontDistributionDomain,
  cloudFrontPrivateKeySecretName,
  cloudFrontPublicKeyId,
} from '../variables';
import { GenerateUploadSignedUrlResponse } from '../types/videoFile';
import { VarException } from '../exceptions/VarException';
import { fileCases } from '../exceptions/cases/fileCases';

// Initialize the AWS Secrets Manager client
const secretsManagerClient = new SecretsManagerClient({
  region: awsRegion,
});

async function getSecretValue(secretName: string): Promise<string> {
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await secretsManagerClient.send(command);
  if (response.SecretString) {
    return response.SecretString;
  }
  throw new Error('Secret not found or is not a string.');
}

// Generate the signed URL
export const generateSignedUrl = async (
  s3Key: string
): Promise<GenerateUploadSignedUrlResponse> => {
  try {
    // Fetch the private key and key pair ID from AWS Secrets Manager
    const privateKey = await getSecretValue(cloudFrontPrivateKeySecretName);

    // Define the URL to sign
    const resourceUrl = `https://${cloudfrontDistributionDomain}/${s3Key}`;

    // Define the expiration time (3 hours from now)
    const expiration = new Date();
    expiration.setHours(expiration.getHours() + 3);

    const signedUrl = getSignedUrl({
      url: resourceUrl,
      dateLessThan: expiration.toISOString(),
      keyPairId: cloudFrontPublicKeyId,
      privateKey,
    });

    return {
      url: signedUrl,
      expiration: expiration.getTime(),
    };
  } catch (e) {
    throw new VarException(fileCases.generateSignedUrl.FailedToGenerateUrl, e);
  }
};
