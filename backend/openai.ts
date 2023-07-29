import { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";

export async function handler(
    event: APIGatewayEvent
): Promise<APIGatewayProxyResult> {
    const openApiKey = process.env.OPENAI_API_KEY;

    if (!openApiKey) {
        return {
            statusCode: 500,
            body: "OpenAI API KEY NOT FOUND!!",
        };
    }
}