import {
  AdminCreateUserCommand,
  AdminCreateUserCommandOutput,
  AdminGetUserCommand,
  AdminGetUserCommandOutput,
  CognitoIdentityProviderClient,
  ListUsersCommand,
  ListUsersCommandOutput,
  AdminDeleteUserCommand,
  AdminDeleteUserCommandOutput
} from '@aws-sdk/client-cognito-identity-provider';
import { CreateUserParams } from '../types/types';
import { awsRegion, userPoolId } from '../variables';

export class AWSCognito {
  private readonly awsRegion: string;
  private readonly userPoolId: string;
  private readonly client: CognitoIdentityProviderClient;

  constructor() {
    this.awsRegion = awsRegion;
    this.userPoolId = userPoolId;
    this.client = new CognitoIdentityProviderClient({
      region: this.awsRegion,
    });
  }

  async createUser(
    params: CreateUserParams
  ): Promise<AdminCreateUserCommandOutput> {
    const { given_name, family_name, email } = params;

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

    return await this.client.send(command);
  }

  async listUsers(): Promise<ListUsersCommandOutput> {
    const command = new ListUsersCommand({
      UserPoolId: this.userPoolId,
      Limit: 60,
    });

    return await this.client.send(command);
  }

  async getUser(username: string): Promise<AdminGetUserCommandOutput> {
    const command = new AdminGetUserCommand({
      UserPoolId: this.userPoolId,
      Username: username,
    });

    return await this.client.send(command);
  }

  async deleteUser(username: string): Promise<AdminDeleteUserCommandOutput> {
    const command = new AdminDeleteUserCommand({
      UserPoolId: this.userPoolId,
      Username: username,
    });

    return await this.client.send(command);
  }
}
