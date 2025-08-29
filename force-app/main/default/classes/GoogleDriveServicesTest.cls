@isTest
public class GoogleDriveServicesTest {
	private static final String PARENT_FOLDER_ID = '1QM78YQvzBbbykitHvP1O1en_ouVUZ8Ax';

    // Mock class for Google Drive API callouts
    private class GoogleDriveMock implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        private String status;
        private Integer callCount = 0;
        private Map<Integer, String> responseMap;

        // Constructor for single response
        public GoogleDriveMock(String responseBody, Integer statusCode, String status) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
            this.status = status;
        }

        // Constructor for multiple responses (bulk test)
        public GoogleDriveMock(Map<Integer, String> responseMap, Integer statusCode, String status) {
            this.responseMap = responseMap;
            this.statusCode = statusCode;
            this.status = status;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (responseMap != null) {
                // Return response based on call count for bulk scenarios
                String body = responseMap.get(callCount);
                res.setBody(body != null ? body : '{"error": {"message": "No response for call count"}}');
                callCount++;
            } else {
                res.setBody(responseBody);
            }
            res.setStatusCode(statusCode);
            res.setStatus(status);
            return res;
        }
    }

    @TestSetup
    static void setup() {
        GoogleDrive__c sandboxSetting = new GoogleDrive__c(
            Name = 'Sandbox',
            parentFolderId__c = PARENT_FOLDER_ID
        );
        GoogleDrive__c prodSetting = new GoogleDrive__c(
            Name = 'Production',
            parentFolderId__c = PARENT_FOLDER_ID
        );
        insert new List<GoogleDrive__c>{ sandboxSetting, prodSetting };
    }

    @isTest
    static void testCreateFolderWithAccountIdSuccess() {
        String mockFolderResponse = '{"id": "testFolderId123", "parents": ["' + PARENT_FOLDER_ID + '"]}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockFolderResponse, 200, 'OK'));

        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Test.startTest();
        String folderId = GoogleDriveServices.createFolder(null, acc.Id);
        Test.stopTest();

        // Verify folder ID and Account update
        System.assertEquals('testFolderId123', folderId, 'Folder ID should be returned');
        Account updatedAcc = [SELECT Google_Drive_Folder_Id__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals('testFolderId123', updatedAcc.Google_Drive_Folder_Id__c, 'Folder ID should be set on Account');
    }

    @isTest
    static void testCreateFolderWithFolderNameSuccess() {
        String mockFolderResponse = '{"id": "testFolderId456", "parents": ["' + PARENT_FOLDER_ID + '"]}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockFolderResponse, 200, 'OK'));

        Test.startTest();
        String folderId = GoogleDriveServices.createFolder('Custom Folder', null);
        Test.stopTest();

        System.assertEquals('testFolderId456', folderId, 'Folder ID should be returned');
    }

    @isTest
    static void testCreateFolderFailure() {
        String mockErrorResponse = '{"error": {"message": "Failed to create folder"}}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockErrorResponse, 400, 'Bad Request'));

        Test.startTest();
        try {
            GoogleDriveServices.createFolder('Test Folder', null);
            System.assert(false, 'Expected exception for failed folder creation');
        } catch (CalloutException e) {
            String expectedMessage = 'Error creating folder: Bad Request - ' + mockErrorResponse;
            System.assertEquals(expectedMessage, e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }

    @isTest
    static void testUploadFileSuccess() {
        String mockFileResponse = '{"id": "testFileId789"}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockFileResponse, 200, 'OK'));

        String folderId = 'testFolderId123';
        String fileName = 'testfile.txt';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test content'));
        String mimeType = 'text/plain';

        Test.startTest();
        String fileId = GoogleDriveServices.uploadFile(folderId, fileName, base64Data, mimeType);
        Test.stopTest();

        System.assertEquals('testFileId789', fileId, 'File ID should be returned');
    }

    @isTest
    static void testUploadFileInvalidFolderId() {
        Test.startTest();
        try {
            GoogleDriveServices.uploadFile(null, 'testfile.txt', EncodingUtil.base64Encode(Blob.valueOf('Test content')), 'text/plain');
            System.assert(false, 'Expected exception for null folder ID');
        } catch (CalloutException e) {
            System.assertEquals('Folder ID is null', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }

    @isTest
    static void testUploadFileFailure() {
        String mockErrorResponse = '{"error": {"message": "Failed to upload file"}}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockErrorResponse, 400, 'Bad Request'));

        String folderId = 'testFolderId123';
        String fileName = 'testfile.txt';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test content'));
        String mimeType = 'text/plain';

        Test.startTest();
        try {
            GoogleDriveServices.uploadFile(folderId, fileName, base64Data, mimeType);
            System.assert(false, 'Expected exception for failed upload');
        } catch (CalloutException e) {
            String expectedMessage = 'Error uploading file: Bad Request - ' + mockErrorResponse;
            System.assertEquals(expectedMessage, e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }

    @isTest
    static void testCustomSettingInitialization() {
        GoogleDrive__c settings = GoogleDriveServices.oauthSettings;
        System.assertNotEquals(null, settings, 'Custom settings should be initialized');
        System.assertEquals(PARENT_FOLDER_ID, settings.parentFolderId__c, 'Parent folder ID should match custom setting');
    }
    

    @isTest
    static void testFutureMethodErrorHandling() {
        String mockErrorResponse = '{"error": {"message": "Failed to create folder"}}';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock(mockErrorResponse, 400, 'Bad Request'));
        
        Account acc = new Account(Name = 'Test Account');
        
        Test.startTest();
        insert acc; 
        Test.stopTest();

        Account updatedAcc = [SELECT Google_Drive_Folder_Id__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(null, updatedAcc.Google_Drive_Folder_Id__c, 'Folder ID should not be set on Account due to error');
    }

}