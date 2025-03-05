import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))  # Log the entire event

    try:
        # Use the event directly (no need to extract 'body')
        body = event
        print("Parsed body:", body)  # Log the parsed body

        # Check for required fields
        required_fields = ['username', 'password', 'email', 'phone']
        if not all(field in body for field in required_fields):
            print("Missing required fields:", required_fields)  # Log missing fields
            return {
                'statusCode': 400,
                'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
                },
                'body': json.dumps({'error': 'Missing required fields'})
            }

        # Insert the user into DynamoDB
        table.put_item(Item=body)
        print("User inserted successfully:", body)  # Log successful insertion

        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            'body': json.dumps({'message': 'User registered successfully!'})
        }
    except Exception as e:
        print("Error:", str(e))  # Log any errors
        return {
            'statusCode': 500,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            'body': json.dumps({'error': str(e)})
        }
