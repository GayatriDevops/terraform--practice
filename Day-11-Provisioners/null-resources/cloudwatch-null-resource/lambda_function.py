import json
import boto3
import gzip
import base64
from datetime import datetime

# Initialize AWS clients
s3 = boto3.client('s3')

# Environment variable for S3 bucket name
S3_BUCKET = os.environ['S3_BUCKET']

def lambda_handler(event, context):
    # Log the event to check its structure
    print("Received event:", json.dumps(event, indent=2))

    # Get log group and log stream from the event
    log_group = event['logGroup']
    log_stream = event['logStream']

    # Fetch log events
    log_events = event['logEvents']
    
    # Create a filename for the log file in S3
    file_name = f"{log_group}/{log_stream}/{datetime.utcnow().isoformat()}.log"

    # Prepare the log data to be saved to S3
    log_data = "\n".join([log_event['message'] for log_event in log_events])

    # Upload log data to S3
    try:
        s3.put_object(Bucket=S3_BUCKET, Key=file_name, Body=log_data, ContentType="text/plain")
        print(f"Successfully uploaded logs to S3: {file_name}")
        return {
            'statusCode': 200,
            'body': json.dumps('Logs successfully exported to S3')
        }
    except Exception as e:
        print(f"Error uploading logs to S3: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Failed to export logs to S3')
        }
