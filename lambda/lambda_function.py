import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("resume-visitor-count")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json",
}


def lambda_handler(event, context):
    # Atomic increment — avoids a get-then-put race if two visitors land
    # at the same moment.
    response = table.update_item(
        Key={"id": "count"},
        UpdateExpression="ADD #v :inc",
        ExpressionAttributeNames={"#v": "views"},
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )
    views = int(response["Attributes"]["views"])

    return {
        "statusCode": 200,
        "headers": CORS_HEADERS,
        "body": json.dumps({"views": views}),
    }
