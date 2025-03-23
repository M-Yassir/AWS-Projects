import json
import boto3
import base64
import uuid

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')

BUCKET_NAME = "m-employee-images-bucket"
TABLE_NAME = "employees"
COLLECTION_ID = "employee_faces"

# Create the Face Collection if it doesn't exist
def create_face_collection():
    try:
        rekognition.create_collection(CollectionId=COLLECTION_ID)
    except rekognition.exceptions.ResourceAlreadyExistsException:
        pass  # Collection already exists

create_face_collection()

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        name = body['name']
        image_data = body['image']

        # Convert image to bytes
        image_bytes = base64.b64decode(image_data)
        temp_image_key = "temp/temp_register.jpg"

        # Upload temp image to S3 for checking
        s3.put_object(Bucket=BUCKET_NAME, Key=temp_image_key, Body=image_bytes, ContentType="image/jpeg")

        # Check if the face is already indexed
        search_response = rekognition.search_faces_by_image(
            CollectionId=COLLECTION_ID,
            Image={'S3Object': {'Bucket': BUCKET_NAME, 'Name': temp_image_key}},
            FaceMatchThreshold=95
        )

        if search_response["FaceMatches"]:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "This face is already registered in the system!"})
            }

        # Register new employee
        employee_id = str(uuid.uuid4())
        image_key = f"employees/{employee_id}.jpg"

        # Upload permanent image to S3
        s3.put_object(Bucket=BUCKET_NAME, Key=image_key, Body=image_bytes, ContentType="image/jpeg")

        # Store in DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item={
            "employee_id": employee_id,
            "name": name,
            "image_url": f"https://{BUCKET_NAME}.s3.amazonaws.com/{image_key}"
        })

        # Index the face in Rekognition Collection
        rekognition.index_faces(
            CollectionId=COLLECTION_ID,
            Image={'S3Object': {'Bucket': BUCKET_NAME, 'Name': image_key}},
            ExternalImageId=employee_id,
            DetectionAttributes=['ALL']
        )

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Employee Registered Successfully!"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": f"Server Error: {str(e)}"})
        }