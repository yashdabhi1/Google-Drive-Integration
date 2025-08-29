public with sharing class GoogleDriveServiceFuture {
    @future(callout=true)
    public static void createFolderFuture(Id accountId, String accountName) {
        try {
            String folderId = GoogleDriveServices.createFolder(accountName, accountId);
        } catch (Exception e) {
            System.debug('Error creating Google Drive folder for Account ' + accountId + ': ' + e.getMessage()); 
        }
    }
}