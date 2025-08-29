# Google Drive Integration for Salesforce

This project is a Salesforce implementation that integrates with Google Drive to manage folder creation and file uploads for Account records. It leverages Salesforce Apex, Lightning Web Components (LWC), and Google Drive API to provide a seamless file management experience within Salesforce. This project is showcased in my portfolio to demonstrate expertise in Salesforce development, API integration, and front-end component design. The code is also hosted on GitHub for public access and contribution.

## Table of Contents
- [Features](#features)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Testing](#testing)
- [Portfolio Context](#portfolio-context)
- [Contributing](#contributing)
- [License](#license)

## Features
- **Folder Creation**: Automatically creates a Google Drive folder for a Salesforce Account using the Account name or a custom folder name.
- **File Upload**: Allows users to upload files to the associated Google Drive folder from a Salesforce Lightning Web Component.
- **Custom Settings**: Configures Google Drive settings for Sandbox and Production environments using Salesforce Custom Settings.
- **Error Handling**: Robust error handling for API callouts, including validation for missing folder IDs and failed API requests.
- **Asynchronous Processing**: Utilizes `@future` methods for non-blocking folder creation to enhance performance.
- **User Interface**: A responsive Lightning Web Component for folder creation and file uploads with real-time feedback via toast notifications.

## Architecture
The project is built on Salesforce with the following components:
- **Apex Classes**:
  - `GoogleDriveServices.cls`: Core logic for interacting with Google Drive API to create folders and upload files.
  - `GoogleDriveServiceFuture.cls`: Handles asynchronous folder creation using `@future` methods.
  - `GoogleDriveServicesTest.cls`: Comprehensive test class with mock callouts to ensure code coverage and reliability.
- **Lightning Web Component**:
  - `fileuploader.html`, `fileuploader.js`, `fileuploader.css`: A user-friendly interface for uploading files and creating folders, styled with CSS and integrated with Apex methods.
- **Flow**:
  - `Update_Account_Folder_Id.flow-meta.xml`: Updates the Account record with the Google Drive folder ID after creation.
- **Custom Settings**:
  - `GoogleDrive__c`: Stores parent folder IDs for Sandbox and Production environments.

The integration uses the Google Drive API v3 with a named credential (`callout:GoogleDrive`) for secure authentication.

## Setup Instructions
To set up this project in your Salesforce org and deploy it to GitHub:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/google-drive-salesforce-integration.git
   ```

2. **Salesforce Setup**:
   - **Named Credential**: Configure a Named Credential in Salesforce named `GoogleDrive` with Google Drive API credentials (OAuth 2.0).
   - **Custom Settings**: Create `GoogleDrive__c` custom settings with `parentFolderId__c` for Sandbox and Production environments (e.g., `1QM78YQvzBbbykitHvP1O1en_ouVUZ8Ax`).
   - **Account Custom Field**: Ensure the `Google_Drive_Folder_Id__c` field exists on the Account object.
   - **Deploy Code**: Deploy the Apex classes, LWC, and Flow using Salesforce CLI or a deployment tool:
     ```bash
     sfdx force:source:deploy -p force-app
     ```

3. **Google Drive API**:
   - Enable the Google Drive API in your Google Cloud Console.
   - Generate OAuth 2.0 credentials and configure the Named Credential in Salesforce.

4. **GitHub Deployment**:
   - Push the code to your GitHub repository:
     ```bash
     git add .
     git commit -m "Initial commit for Google Drive integration"
     git push origin main
     ```

5. **Permissions**:
   - Assign necessary permissions to users for accessing the LWC and Apex classes.
   - Ensure the user profile has access to the `GoogleDrive__c` custom settings and the `Account` object.

## Usage
1. **Add the LWC to a Record Page**:
   - Add the `FileUploader` LWC to an Account record page via the Lightning App Builder.
2. **Create a Folder**:
   - If no Google Drive folder exists for the Account, click the "Create Folder" button to create one.
   - The folder ID is stored in the `Google_Drive_Folder_Id__c` field on the Account.
3. **Upload Files**:
   - Select a file using the file input field.
   - Click "Upload" to send the file to the associated Google Drive folder.
   - Receive success or error notifications via toast messages.
4. **Monitor API Calls**:
   - API responses are logged in Salesforce debug logs for troubleshooting.

## File Structure
```plaintext
force-app/
├── main/
│   ├── default/
│   │   ├── classes/
│   │   │   ├── GoogleDriveServices.cls
│   │   │   ├── GoogleDriveServiceFuture.cls
│   │   │   ├── GoogleDriveServicesTest.cls
│   │   ├── flows/
│   │   │   ├── Update_Account_Folder_Id.flow-meta.xml
│   │   ├── lwc/
│   │   │   ├── fileuploader/
│   │   │   │   ├── fileuploader.html
│   │   │   │   ├── fileuploader.js
│   │   │   │   ├── fileuploader.css
├── README.md
```

## Testing
The `GoogleDriveServicesTest.cls` provides comprehensive test coverage for the Apex logic:
- **Test Scenarios**:
  - Folder creation with Account ID and custom folder name.
  - File upload success and failure cases.
  - Error handling for invalid folder IDs and API failures.
  - Custom settings initialization.
  - Asynchronous folder creation error handling.
- **Mock Callouts**: Uses `HttpCalloutMock` to simulate Google Drive API responses.
- **Execution**:
  ```bash
  sfdx force:apex:test:run -c -r human
  ```

## Portfolio Context
This project is featured in my portfolio to highlight my skills in:
- **Salesforce Development**: Proficiency in Apex, LWC, and Salesforce Flow.
- **API Integration**: Expertise in integrating third-party APIs (Google Drive API) with Salesforce.
- **Front-End Development**: Building responsive and user-friendly interfaces with LWC and CSS.
- **Testing and Reliability**: Writing robust unit tests with mock callouts to ensure code quality.
- **Asynchronous Processing**: Implementing `@future` methods for efficient API handling.

View the project on GitHub: [github.com/your-username/google-drive-salesforce-integration](https://github.com/your-username/google-drive-salesforce-integration)

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please ensure your code follows Salesforce best practices and includes test coverage.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.