import os, boto3
from botocore.exceptions import ClientError
import logging

logger = logging.getLogger("app")

# TABLE_NAME must be provided via ECS task environment
_table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

def put_mapping(short_id: str , url: str):
    try:
        _table.put_item(Item={"id": short_id, "url": url})
    except ClientError as e:
        logger.exception("DDB PutItem failed: %s", e.response.get("Error"))
        raise

def get_mapping(short_id: str):
    try:
        resp = _table.get_item(Key={"id": short_id})
        return resp.get("Item")
    except ClientError as e:
        logger.exception("DDB GetItem failed: %s", e.response.get("Error"))
        raise
