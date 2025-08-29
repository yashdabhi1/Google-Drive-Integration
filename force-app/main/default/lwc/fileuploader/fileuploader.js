import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/GoogleDriveServices.uploadFile';
import createFolder from '@salesforce/apex/GoogleDriveServices.createFolder';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import FOLDER_ID_FIELD from '@salesforce/schema/Account.Google_Drive_Folder_Id__c';
import { refreshApex } from '@salesforce/apex';

export default class FileUploader extends LightningElement {
    @api recordId;
    @track hasFolder = false;
    @track fileData;
    @track isLoading = false;
    @track error;
    @track isFileSelected = false; 
    @track selectedFileName = '';
    @track filesUploaded = [];
    wiredAccountResult;

    @wire(getRecord, { recordId: '$recordId', fields: [FOLDER_ID_FIELD] })
    accountRecord(result) {
        console.log('Account Record Result:', result);
        this.wiredAccountResult = result;
        if (result.data) {
            this.hasFolder = !!getFieldValue(result.data, FOLDER_ID_FIELD);
            this.error = null;
        } else if (result.error) {
            this.error = 'Error checking folder: ' + result.error.body.message;
            this.hasFolder = false;
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = {
                    filename: file.name,
                    base64: reader.result.split(',')[1],
                    mimeType: file.type
                };
                this.isFileSelected = true; 
                this.selectedFileName = file.name; 
            };
            reader.readAsDataURL(file);
        } else {
            this.fileData = null;
            this.isFileSelected = false; 
            this.selectedFileName = '';
        }
    }

    handleRemoveFile() {
        this.fileData = null;
        this.isFileSelected = false; 
        this.selectedFileName = '';
        this.template.querySelector('lightning-input').value = null;
    }

    handleUpload() {
        this.isLoading = true;
        this.error = null;
        const folderId = getFieldValue(this.wiredAccountResult.data, FOLDER_ID_FIELD);
        if (!folderId) {
            this.isLoading = false;
            this.error = 'Cannot upload file: No Google Drive folder exists for this Account.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error'
                })
            );
            return;
        }
        const { filename, base64, mimeType } = this.fileData;
        uploadFile({
            folderId: folderId,
            fileName: filename,
            base64Data: base64,
            mimeType: mimeType
        })
        .then(result => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `${filename} uploaded successfully!`,
                    variant: 'success'
                })
            );
            this.fileData = null;
            this.isFileSelected = false; 
            this.selectedFileName = ''; 
            this.template.querySelector('lightning-input').value = null;
        })
        .catch(error => {
            this.isLoading = false;
            this.error = 'Upload failed: ' + error.body.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error'
                })
            );
        });
    }

    removeFile(event) {
        const index = event.target.dataset.index;
        this.filesUploaded.splice(index,1);
        if (this.filesUploaded.length === 0) {
            this.fileup1 = false;
        }
    }  

    handleCreateFolder() {
        this.isLoading = true;
        this.error = null;
        createFolder({ folderName: '', accountId: this.recordId })
        .then(() => refreshApex(this.wiredAccountResult))
        .then(result => {
            this.isLoading = false;
            this.hasFolder = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Google Drive folder created!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.isLoading = false;
            this.error = 'Folder creation failed: ' + error.body.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error'
                })
            );
        });
    }
}