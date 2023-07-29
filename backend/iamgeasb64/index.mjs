import http from 'http';
import https from 'https';

export async function handler(event) {
    const imageUrl = event.queryStringParameters?.imageUrl;

    const headers = {
        // 
    }

    if (!imageUrl) {
        return {
            statusCode: 400,
            headers,
            body: JSON.stringify({
                success: false,
                message: 'Image URL params',
            }),
        };
    }

    const httpModule = imageUrl.startsWith('https') ? https : http;

    try {
        const base64Image = await new Promise((resolve, reject) => {
            httpModule
        })
    } catch (error) {
        console.error('Error fetching IMAGE', error);
        return {
            statusCode: 500
        }
    }
}