import {
  AdminCreateUserCommand,
  ListUsersCommand,
  AdminCreateUserCommandOutput,
  CognitoIdentityProviderClient, ListUsersCommandOutput,
} from '@aws-sdk/client-cognito-identity-provider';
import { CreateUserParams } from '../types';
import { userPoolId } from '../variables';
import { awsRegion } from '../shared/variables';

export class AWSCognito {
  private awsRegion: string;
  private userPoolId: string;

  constructor() {
    this.awsRegion = awsRegion;
    this.userPoolId = userPoolId;
  }

  async create(
    params: CreateUserParams
  ): Promise<AdminCreateUserCommandOutput> {
    const { given_name, family_name, email } = params;

    const client = new CognitoIdentityProviderClient({
      region: this.awsRegion,
    });

    const command = new AdminCreateUserCommand({
      UserPoolId: this.userPoolId,
      Username: email,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'given_name', Value: given_name },
        { Name: 'family_name', Value: family_name || '' },
      ],
      MessageAction: 'SUPPRESS',
    });

    const createdUser = await client.send(command);
    console.log('Cognito user created:', createdUser);
    return createdUser;
  }

  async list(
  ): Promise<ListUsersCommandOutput> {
    const client = new CognitoIdentityProviderClient({
      region: this.awsRegion,
    });

    const command = new ListUsersCommand({
      UserPoolId: this.userPoolId,
      Limit: 60
    });

    const users = await client.send(command);
    console.log('Got cognito users list:', users);
    return users;
  }
}
