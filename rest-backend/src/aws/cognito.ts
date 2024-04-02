import {
  AdminCreateUserCommand,
  AdminCreateUserCommandOutput,
  AdminGetUserCommand,
  AdminGetUserCommandOutput,
  CognitoIdentityProviderClient,
  ListUsersCommand,
  ListUsersCommandOutput,
  AdminDeleteUserCommand,
  AdminDeleteUserCommandOutput, AdminUpdateUserAttributesCommandOutput, AdminUpdateUserAttributesCommand, AttributeType,
} from '@aws-sdk/client-cognito-identity-provider';
import { CreateUserParams, UpdateUserParams } from '../types/types';
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

  async updateUser(
    username: string,
    params: UpdateUserParams
  ): Promise<AdminUpdateUserAttributesCommandOutput> {
    const { given_name, family_name, email } = params;
    const attributes: AttributeType[] = [];
    if (given_name) {
      attributes.push({ Name: 'given_name', Value: given_name });
    }
    if (family_name) {
      attributes.push({ Name: 'family_name', Value: family_name},);
    }
    if (email) {
      attributes.push({ Name: 'email', Value: email });
    }
    const command = new AdminUpdateUserAttributesCommand({
      UserPoolId: this.userPoolId,
      Username: username,
      UserAttributes: attributes,
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
