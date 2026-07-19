import os
import sys
from pathlib import Path

# lambda_function.py lives one directory up from tests/ and isn't a package,
# so put it on sys.path directly rather than fighting with relative imports.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

# moto intercepts these at the botocore layer, but boto3.resource() still
# wants *something* present in the environment before it'll build a client.
os.environ.setdefault("AWS_ACCESS_KEY_ID", "testing")
os.environ.setdefault("AWS_SECRET_ACCESS_KEY", "testing")
os.environ.setdefault("AWS_SECURITY_TOKEN", "testing")
os.environ.setdefault("AWS_SESSION_TOKEN", "testing")
os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")
