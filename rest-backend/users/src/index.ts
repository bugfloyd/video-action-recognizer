import { CognitoIdentityProviderClient, ListUsersCommand, ListUsersCommandInput, UserType } from "@aws-sdk/client-cognito-identity-provider";
import { APIGatewayProxyHandler } from 'aws-lambda';

interface LambdaResponse {
    statusCode: number;
    headers?: {
        [header: string]: string;
    };
    body: string;
}

export const handler: APIGatewayProxyHandler = async (): Promise<LambdaResponse> => {
    const region = process.env.REGION;
    const userPoolId = process.env.USER_POOL_ID; 

    const client = new CognitoIdentityProviderClient({ region });

    const listUsers = async (accumulatedUsers: UserType[] = [], paginationToken?: string): Promise<UserType[]> => {
        const params: ListUsersCommandInput = {
            UserPoolId: userPoolId,
            Limit: 60, // Adjust the limit as needed
            PaginationToken: paginationToken
        };

        const command = new ListUsersCommand(params);
        const response = await client.send(command);

        const users = accumulatedUsers.concat(response.Users || []);
        if (response.PaginationToken) {
            return listUsers(users, response.PaginationToken);
        }
        return users;
    };

    try {
        const users = await listUsers();
        return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*", // For CORS
                "Access-Control-Allow-Credentials": "true"
            },
            body: JSON.stringify(users)
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Internal Server Error' })
        };
    }
};
