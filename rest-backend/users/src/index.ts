import {
  APIGatewayProxyEvent,
  APIGatewayProxyHandler,
  APIGatewayProxyResult,
} from 'aws-lambda'

export const handler: APIGatewayProxyHandler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const httpMethod = event.httpMethod
  const pathParameters = event.pathParameters
  const userId = pathParameters ? pathParameters['user_id'] : null

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Request processed successfully',
      method: httpMethod,
      userId,
    }),
  }
}
