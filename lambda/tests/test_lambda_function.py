import importlib
import json

import boto3
import pytest
from moto import mock_aws

TABLE_NAME = "resume-visitor-count"


@pytest.fixture
def lambda_module():
    """Spin up a mocked DynamoDB table and (re)import lambda_function against it.

    lambda_function.py creates its `dynamodb`/`table` objects at import time,
    so the mock has to be active *before* the module is imported — hence the
    reload inside the `with mock_aws()` block rather than a plain import at
    the top of this file.
    """
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        dynamodb.create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )

        import lambda_function

        importlib.reload(lambda_function)
        yield lambda_function


def test_first_invocation_starts_count_at_one(lambda_module):
    result = lambda_module.lambda_handler({}, {})
    body = json.loads(result["body"])
    assert body["views"] == 1


def test_repeated_invocations_increment_sequentially(lambda_module):
    lambda_module.lambda_handler({}, {})
    lambda_module.lambda_handler({}, {})
    result = lambda_module.lambda_handler({}, {})

    body = json.loads(result["body"])
    assert body["views"] == 3


def test_response_shape_and_cors_headers(lambda_module):
    result = lambda_module.lambda_handler({}, {})

    assert result["statusCode"] == 200
    assert result["headers"]["Access-Control-Allow-Origin"] == "*"
    assert result["headers"]["Content-Type"] == "application/json"

    body = json.loads(result["body"])
    assert isinstance(body["views"], int)
    assert set(body.keys()) == {"views"}


def test_views_is_json_serializable_int_not_decimal(lambda_module):
    # DynamoDB returns numbers as Decimal; the handler must cast to int
    # before json.dumps or this raises TypeError instead of returning 200.
    result = lambda_module.lambda_handler({}, {})
    body = json.loads(result["body"])
    assert type(body["views"]) is int
