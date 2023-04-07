from boto3 import session
from botocore.client import Config
import io
import os

ACCESS_ID = os.environ.get('ACCESS_ID')
SECRET_KEY = os.environ.get('SECRET_KEYI')
ENDPOINT = os.environ.get('ENDPOINT')

session = session.Session()
client = session.client('s3',
                        region_name='nyc3',
                        endpoint_url=ENDPOINT,
                        aws_access_key_id=ACCESS_ID,
                        aws_secret_access_key=SECRET_KEY)


def upload_avatar(file, name):
    client.upload_fileobj(io.BytesIO(file), 'avatars',
                          name, ExtraArgs={'ACL': 'public-read', 'ContentType': 'image/jpeg', })


def upload_header(file, name):
    client.upload_fileobj(io.BytesIO(file), 'headers',
                          name, ExtraArgs={'ACL': 'public-read', 'ContentType': 'image/jpeg', })
