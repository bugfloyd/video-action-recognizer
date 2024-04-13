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
import { GenerateSignedUrlResponse } from '../types/types';

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
  s3Key: string,
  expirationDate: Date
): Promise<GenerateSignedUrlResponse> => {
  // Fetch the private key and key pair ID from AWS Secrets Manager
  const privateKey = await getSecretValue(cloudFrontPrivateKeySecretName);

  // Define the URL to sign
  const resourceUrl = `https://${cloudfrontDistributionDomain}/${s3Key}`;

  const signedUrl = getSignedUrl({
    url: resourceUrl,
    dateLessThan: expirationDate.toISOString(),
    keyPairId: cloudFrontPublicKeyId,
    privateKey,
  });

  return {
    url: signedUrl,
    expiration: expirationDate.getTime(),
  };
};
