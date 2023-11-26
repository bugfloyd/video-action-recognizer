import { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event) => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    // Create response
    const response = {
        statusCode: 200,
        body: JSON.stringify('Success'),
    };

    return response;
};