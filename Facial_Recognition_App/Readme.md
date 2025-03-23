## Serverless Face Recognition Application 🚀

# Introduction
Welcome to the Serverless Face Recognition Application repository! This project demonstrates the development of a fully serverless biometric authentication system using Amazon Web Services (AWS).
The application enables secure and efficient employee registration and login through facial recognition technology, eliminating the need for passwords while ensuring high security.
This system is fully serverless, leveraging AWS services like Lambda, API Gateway, Rekognition, S3, and DynamoDB to create a scalable, cost-efficient, and highly available authentication platform.
Built entirely within the AWS Free Tier, it showcases the power of cloud computing, AI-based authentication, and serverless architecture.

# Key Features
✅ Employee Registration:

Admins register employees by submitting their name and image.
The image is temporarily stored in Amazon S3, and AWS Rekognition checks if the face already exists.
If the face is not found, the image is permanently stored in S3, indexed in Rekognition, and employee details (name, ID, image URL) are saved in DynamoDB.
The system prevents duplicate registrations, even if an employee uploads a different image (e.g., different pose or angle).
✅ Employee Login:

Employees authenticate by uploading their image, which is temporarily stored in S3.
Rekognition searches for the face in the indexed collection.
If a match is found, the employee is successfully authenticated, and their details are retrieved from DynamoDB and displayed.
If no match is found, an error message is shown.
✅ Serverless Architecture:

AWS Lambda: Handles backend logic, ensuring scalability and cost efficiency.
Amazon API Gateway: Exposes REST APIs for employee registration and authentication.
Amazon DynamoDB: Stores employee data, ensuring quick lookups and high availability.
Amazon S3: Used for secure image storage.
AWS Rekognition: Powers AI-based facial recognition, enabling automated authentication.
✅ Static Website Hosting:

The frontend is built with HTML, CSS, and JavaScript and hosted on Amazon S3.
Provides a cost-effective and scalable solution for web hosting.

# AWS Services Used
Amazon S3
Used for secure storage of employee images. Images are first uploaded temporarily before being permanently stored once verified by Rekognition.

Amazon Rekognition
Handles facial recognition and matching. It detects faces in uploaded images and compares them with the stored database to authenticate employees.

Amazon DynamoDB
Acts as the central database for storing employee records, including name, unique ID, and image URLs. It provides fast, scalable, and efficient data retrieval.

AWS Lambda
Powers the backend logic, handling image uploads, Rekognition API calls, and DynamoDB interactions without needing a dedicated server.

Amazon API Gateway
Serves as the interface between the frontend and backend, allowing secure communication between the web application and AWS Lambda functions.

# Video Demonstration 📹
https://github.com/user-attachments/assets/6756a791-ed39-47a5-8e12-c88cabc3db63

#Important Note 🚨
These projects have been terminated for security reasons. Feel free to explore the code and documentation, but be aware that the projects are no longer active or maintained.

# Getting Started
Clone the Repository: git clone https://github.com/M-Yassir/AWS-Projects.git

Navigate to the Project Directory: cd Facial_Recognition_App

Follow the Documentation: Check out the detailed docs to set up the app.

# Contributing
We welcome contributions! If you have any suggestions or improvements, feel free to submit issues or pull requests.
