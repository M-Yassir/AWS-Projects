import json
import boto3
import base64

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')

BUCKET_NAME = "m-employee-images-bucket"
TABLE_NAME = "employees"
COLLECTION_ID = "employee_faces"  # Rekognition Collection Name

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        image_data = body['image']  # Only image is needed for login

        # Convert image to bytes
        image_bytes = base64.b64decode(image_data)
        temp_image_key = "temp/temp_login.jpg"

        # Upload temp image to S3 for face search
        s3.put_object(Bucket=BUCKET_NAME, Key=temp_image_key, Body=image_bytes, ContentType="image/jpeg")

        # Search for the face in the Rekognition collection
        search_response = rekognition.search_faces_by_image(
            CollectionId=COLLECTION_ID,
            Image={'S3Object': {'Bucket': BUCKET_NAME, 'Name': temp_image_key}},
            FaceMatchThreshold=95  # Adjust threshold as needed
        )

        # Check if a match was found
        if not search_response["FaceMatches"]:
            return {
                "statusCode": 401,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Face not recognized. Try again."})
            }

        # Get the matched face details
        matched_face = search_response["FaceMatches"][0]
        external_image_id = matched_face["Face"]["ExternalImageId"]  # This is the employee_id

        # Fetch employee details from DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        response = table.get_item(Key={"employee_id": external_image_id})

        if "Item" not in response:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Employee not found in the database."})
            }

        employee_name = response["Item"]["name"]
        image_url = response["Item"]["image_url"]

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "✅ Authentication Successful!",
                "employee_id": external_image_id,
                "name": employee_name,
                "image_url": image_url
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": f"Server Error: {str(e)}"})
        }

