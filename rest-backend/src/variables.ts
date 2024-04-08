export const awsRegion: string = process.env.REGION || '';

export const userPoolId: string = process.env.USER_POOL_ID || '';

export const cloudFrontPublicKeyId: string =
  process.env.CLOUDFRONT_PUBLIC_KEY_ID || '';

export const cloudFrontPrivateKeySecretName: string =
  process.env.CLOUDFRONT_PRIVATE_KEY_SECRET_NAME || '';

export const cloudfrontDistributionDomain: string =
  process.env.CLOUDFRONT_DISTRIBUTION_DOMAIN || '';

export const eventBusName: string =
  process.env.EVENT_BUS_NAME || '';
