import json
import base64
from pyzbar.pyzbar import decode
from PIL import Image
import io



def lambda_handler(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    body = json.loads(event['body'])
    image_64 = body['image']
    #print(image_64)
    image = base64.standard_b64decode(image_64)
    f = io.BytesIO(image)
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "code": decode(Image.open(f))[0].data.decode("latin-1")
            }
        ),
    }
