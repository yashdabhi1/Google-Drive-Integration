public with sharing class GoogleDriveServices {
    public static GoogleDrive__c oauthSettings;
    static {
        Organization org = [SELECT Id, Name, IsSandbox FROM Organization];
        Boolean isSandbox = org.IsSandbox;
        if (isSandbox) {
            oauthSettings = GoogleDrive__c.getValues('Sandbox');
        } else {
            oauthSettings = GoogleDrive__c.getValues('Production');
        }
    }
    public static String parentFolderId = oauthSettings.parentFolderId__c;

    @AuraEnabled
    public static String uploadFile(String folderId, String fileName, String base64Data, String mimeType) {
        try {
            if (String.isBlank(folderId)) {
                throw new CalloutException('Folder ID is null');
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GoogleDrive/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true');
            req.setMethod('POST');
            String metadata = JSON.serialize(new Map<String, Object>{'name' => fileName, 'parents' => new List<String>{folderId}});
            String boundary = '-------314159265358979323846';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String close_delim = '\r\n--' + boundary + '--';
            String requestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + metadata + '\r\n' + delimiter + 'Content-Type: ' + mimeType + '\r\n' +
                'Content-Transfer-Encoding: base64\r\n\r\n' + base64Data + close_delim;
            req.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
            req.setBody(requestBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String fileId = (String) response.get('id');
                return fileId;
            } else {
                throw new CalloutException('Error uploading file: ' + res.getStatus() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static String createFolder(String folderName, String accountId) {
        try {
            if (String.isBlank(folderName) && String.isNotBlank(accountId)) {
                Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
                folderName = acc != null ? acc.Name : null;
            }

            HttpRequest req = new HttpRequest();
            String endpoint = 'callout:GoogleDrive/drive/v3/files?supportsAllDrives=true';
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            
            Map<String, Object> requestBody = new Map<String, Object>{
                'name' => folderName,
                'mimeType' => 'application/vnd.google-apps.folder',
                'parents' => new List<String>{ parentFolderId }
            };
            String body = JSON.serialize(requestBody);
            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String folderId = (String) response.get('id');
                List<Object> parents = (List<Object>) response.get('parents');
                
                Map<String, Object> inputs = new Map<String, Object>{
                    'accountId' => accountId,
                    'folderId' => folderId
                };
                Flow.Interview.Update_Account_Folder_Id flowInterview = new Flow.Interview.Update_Account_Folder_Id(inputs);
                flowInterview.start();
                
                return folderId;
                
            } else {
                throw new CalloutException('Error creating folder: ' + res.getStatus() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw e;
        }
    }
}