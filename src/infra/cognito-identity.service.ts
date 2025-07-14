import {
    AdminCreateUserCommand,
    CognitoIdentityProviderClient,
} from '@aws-sdk/client-cognito-identity-provider';
import {
    AuthenticationDetails,
    CognitoUser,
    CognitoUserPool,
} from 'amazon-cognito-identity-js';
import { User } from '../domain/user.entity';
import { IdentityService } from '../usecases/abstractions/identity.service';

const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION ?? 'us-east-1',
});

export class CognitoIdentityService implements IdentityService {
  private readonly userPoolId = process.env.COGNITO_USER_POOL_ID;
  private readonly clientId = process.env.COGNITO_CLIENT_ID;

  async createUser(user: User): Promise<void> {
    const attributes = [
      { Name: 'name', Value: user.name },
      { Name: 'custom:role', Value: user.role },
    ];

    if (user.cpf) {
      attributes.push({ Name: 'custom:cpf', Value: user.cpf.value });
    }

    if (user.email) {
      attributes.push({ Name: 'email', Value: user.email.value });
    }

    const command = new AdminCreateUserCommand({
      UserPoolId: this.userPoolId,
      Username: user.username,
      TemporaryPassword: user.password,
      MessageAction: 'SUPPRESS',
      UserAttributes: attributes,
    });

    try {
      await cognitoClient.send(command);
    } catch (err) {
      console.error('Failed creating user', err);
      throw new Error('Could not create user');
    }
  }

  async authenticate(user: User): Promise<string> {
    const cognitoUser = new CognitoUser({
      Username: user.username,
      Pool: new CognitoUserPool({
        UserPoolId: this.userPoolId,
        ClientId: this.clientId,
      }),
    });

    const token = await new Promise<string>((resolve, reject) => {
      cognitoUser.authenticateUser(
        new AuthenticationDetails({
          Username: user.username,
          Password: user.password,
        }),
        {
          onSuccess: (result) => {
            resolve(result.getIdToken().getJwtToken());
          },
          onFailure: (err) => {
            console.error('Failed authenticating user', err);
            reject(new Error('Could not authenticate user'));
          },
          newPasswordRequired: async () => {
            const token = await this.newPasswordChallenge(cognitoUser, user);
            resolve(token);
          },
        },
      );
    });

    return token;
  }

  private newPasswordChallenge(
    cognitoUser: CognitoUser,
    user: User,
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      cognitoUser.completeNewPasswordChallenge(user.password, null, {
        onSuccess: async () => {
          const token = await this.authenticate(user);
          resolve(token);
        },
        onFailure: (err) => {
          console.error('Failed setting new user password', err);
          reject(new Error(`Could not set the user's password`));
        },
      });
    });
  }
}
