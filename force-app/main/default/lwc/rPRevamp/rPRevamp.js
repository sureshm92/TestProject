import { LightningElement, api, track, wire } from 'lwc';
import xlsxmin from '@salesforce/resourceUrl/xlsxmin';
import getHCPInitData from '@salesforce/apex/FileContainer.getHCPInitData';
import getShowInstructValue from '@salesforce/apex/FileContainer.getShowInstructValue';
import bulkicons from '@salesforce/resourceUrl/bulkicons';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile';
import fetchFiles from '@salesforce/apex/nonReferedBulkUpload.fetchFiles';
import processvalidateFile from '@salesforce/apex/nonReferedBulkUpload.processvalidateFile';
import deleteFile from '@salesforce/apex/nonReferedBulkUpload.deleteFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import downloadBulkTemplate from '@salesforce/resourceUrl/Import_Patient_Template';

import BulkImport_Instructions from '@salesforce/label/c.BulkImport_Instructions';
import BulkImport_File_Template from '@salesforce/label/c.BulkImport_File_Template';
import BulkImport_File_Name from '@salesforce/label/c.BulkImport_File_Name';
import BulkImport_Accepted from '@salesforce/label/c.BulkImport_Accepted';
import BulkImport_Rejected from '@salesforce/label/c.BulkImport_Rejected';
import BulkImport_Uploaded_By from '@salesforce/label/c.BulkImport_Uploaded_By';
import BulkImport_Uploaded_On from '@salesforce/label/c.BulkImport_Uploaded_On';
import BulkImport_Actions from '@salesforce/label/c.BulkImport_Actions';
import BulkImport_Bulk_Import_Process from '@salesforce/label/c.BulkImport_Bulk_Import_Process';
import BulkImport_Dont_show_me_again_on_landing from '@salesforce/label/c.BulkImport_Dont_show_me_again_on_landing';
import BulkImport_Ok from '@salesforce/label/c.BulkImport_Ok';
import BulkImport_Import_Patients from '@salesforce/label/c.BulkImport_Import_Patients';
import BulkImport_Select_Study_Here from '@salesforce/label/c.BulkImport_Select_Study_Here';
import BulkImport_Select_Study from '@salesforce/label/c.BulkImport_Select_Study';
import BulkImport_Drag_file_here_or from '@salesforce/label/c.BulkImport_Drag_file_here_or';
import BulkImport_browse from '@salesforce/label/c.BulkImport_browse';
import BulkImport_Max_size from '@salesforce/label/c.BulkImport_Max_size';
import BulkImport_Wait_Warning from '@salesforce/label/c.BulkImport_Wait_Warning';
import BulkImport_Import from '@salesforce/label/c.BulkImport_Import';
import BulkImport_Uploaded_format from '@salesforce/label/c.BulkImport_Uploaded_format';
import BulkImport_Total_number from '@salesforce/label/c.BulkImport_Total_number';
import BulkImport_Please_upload_only_csv_xlsx_or_xls_format_files from '@salesforce/label/c.BulkImport_Please_upload_only_csv_xlsx_or_xls_format_files';
import BulkImport_TableHeading from '@salesforce/label/c.BulkImport_TableHeading';
import BulkImport_Initial_Total_Records from '@salesforce/label/c.BulkImport_Initial_Total_Records';
import BulkImport_No_files_to_display from '@salesforce/label/c.BulkImport_No_files_to_display';
import RH_RP_Bulk_format from '@salesforce/label/c.RH_RP_Bulk_format';
import RH_RP_Patients from '@salesforce/label/c.RH_RP_Patients';
import RH_RP_Study_Name from '@salesforce/label/c.RH_RP_Study_Name';
import RH_RP_file from '@salesforce/label/c.RH_RP_file';
import RH_RP_Complete_Select from '@salesforce/label/c.RH_RP_Complete_Select';
import RH_RP_Records from '@salesforce/label/c.RH_RP_Records';
import RH_RP_Referred_Tab from '@salesforce/label/c.RH_RP_Referred_Tab';
import RH_RP_Result_Sheet from '@salesforce/label/c.RH_RP_Result_Sheet';
import RH_RP_Validation_Errors from '@salesforce/label/c.RH_RP_Validation_Errors';
import RH_RP_Rejection_Reason from '@salesforce/label/c.RH_RP_Rejection_Reason';
import RH_RP_File_Name from '@salesforce/label/c.RH_RP_File_Name';
import RH_RP_Rejected_Records from '@salesforce/label/c.RH_RP_Rejected_Records';

const MAX_FILE_SIZE = 2621440; // 4500000; max file size prog can handle
const CHUNK_SIZE = 9000; //750000; max chunk size prog can handle

export default class RPRevamp extends LightningElement {
    BulkImport_No_files_to_display = BulkImport_No_files_to_display;
    BulkImport_Instructions = BulkImport_Instructions;
    BulkImport_File_Template = BulkImport_File_Template;
    BulkImport_File_Name = BulkImport_File_Name;
    BulkImport_Accepted = BulkImport_Accepted;
    BulkImport_Rejected = BulkImport_Rejected;
    BulkImport_Uploaded_By = BulkImport_Uploaded_By;
    BulkImport_Uploaded_On = BulkImport_Uploaded_On;
    BulkImport_Actions = BulkImport_Actions;
    BulkImport_Bulk_Import_Process = BulkImport_Bulk_Import_Process;
    BulkImport_Dont_show_me_again_on_landing = BulkImport_Dont_show_me_again_on_landing;
    BulkImport_Ok = BulkImport_Ok;
    BulkImport_Import_Patients = BulkImport_Import_Patients;
    BulkImport_Select_Study_Here = BulkImport_Select_Study_Here;
    BulkImport_Select_Study = BulkImport_Select_Study;
    BulkImport_Drag_file_here_or = BulkImport_Drag_file_here_or;
    BulkImport_browse = BulkImport_browse;
    BulkImport_Max_size = BulkImport_Max_size;
    BulkImport_Wait_Warning = BulkImport_Wait_Warning;
    BulkImport_Import = BulkImport_Import;
    BulkImport_Uploaded_format = BulkImport_Uploaded_format;
    BulkImport_Total_number = BulkImport_Total_number;
    BulkImport_Please_upload_only_csv_xlsx_or_xls_format_files = BulkImport_Please_upload_only_csv_xlsx_or_xls_format_files;
    BulkImport_TableHeading = BulkImport_TableHeading;
    BulkImport_Initial_Total_Records = BulkImport_Initial_Total_Records;
    RH_RP_Rejected_Records = RH_RP_Rejected_Records;
    RH_RP_File_Name = RH_RP_File_Name;
    RH_RP_Rejection_Reason = RH_RP_Rejection_Reason;
    RH_RP_Validation_Errors = RH_RP_Validation_Errors;
    RH_RP_Result_Sheet = RH_RP_Result_Sheet;
    RH_RP_Referred_Tab = RH_RP_Referred_Tab;
    RH_RP_Records = RH_RP_Records;
    RH_RP_Complete_Select = RH_RP_Complete_Select;
    RH_RP_file = RH_RP_file;
    RH_RP_Study_Name = RH_RP_Study_Name;
    RH_RP_Patients = RH_RP_Patients;
    RH_RP_Bulk_format = RH_RP_Bulk_format;

    templateFile = downloadBulkTemplate;
    instructionsSvgURL = bulkicons + '/instructions.svg';
    downloadSvgURL = bulkicons + '/Download.svg';
    impotrtSvgURL = bulkicons + '/icon.svg';
    @api recordId;
    isloading;
    @track fileList;
    renderTable = false;
    @track isInstrModalOpen = false;
    @track isUploadModalOpen = false;
    @track userMode;
    @track hasAccess;
    @track hcpInitData;
    studies = [];
    @api contentFiles = [];
    rpState;
    rpCountry;
    userConID;
    inProgress = false;
    completed = false;
    loaded = false;
    showInstruction = false;
    nofiles = false;
    @api recordsToDisplay = [];
    baseUrl;
    filesLoaded = false;
    @api isMobileapp = false;

    get dontshowInstruction() {
        return !this.showInstruction;
    }

    connectedCallback() {
        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                //this is the name of the function that’s present
                //in the uploaded static resource.
                const delegateid = communityService.getDelegateId();
                const userMode = communityService.getUserMode();
                const baseUrl = communityService.getBaseUrl();
                this.userMode = userMode;
                this.baseUrl = baseUrl;
                this.loaded = true;
                getHCPInitData({
                    userMode: userMode,
                    delegateId: delegateid
                }).then((result) => {
                    for (var i = 0; i < result.activelyEnrollingStudies.length; i++) {
                        this.studies.push(result.activelyEnrollingStudies[i].studies);
                    }
                    this.userConID = result.delegateDetails.Id;
                    this.rpState = result.delegateDetails.MailingState;
                    this.rpCountry = result.delegateDetails.MailingCountry;
                    this.isInstrModalOpen = result.showInstructions;
                    this.showInstruction = result.showInstructions;
                    this.getDetailsApex();
                });
            });
            loadScript(this, xlsxmin).then(() => {});
        }
    }
    getDetailsApex() {
        this.nofiles = false;
        if (communityService.isMobileSDK()) {
            this.isMobileapp = true;
        }
        fetchFiles({ delegateId: this.userConID })
            .then((result) => {
                this.contentFiles = result;
                this.recordsToDisplay = result;
                this.error = undefined;
                this.filesLoaded = true;
                if (result.length == 0) this.nofiles = true;
            })
            .catch((error) => {
                this.nofiles = true;
                this.contentFiles = undefined;
            });
    }

    /*@wire(fetchFiles) peList(result) {

        if (result.data) {
            this.contentFiles = result.data;
            this.recordsToDisplay = result.data;
            this.error = undefined; 

        } else if (result.error) {
            this.error = result.error;
            this.contentFiles = undefined;
        }
    }*/

    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
    }

    openIntructModal() {
        this.isInstrModalOpen = true;
    }
    //close model for refresh
    closeIntructModal() {
        this.isInstrModalOpen = false;
    }
    downloadFile() {
        const evt = new ShowToastEvent({
            title: '',
            message: 'Opening this link is only supported using the web browser experience',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    openUploadModal() {
        if (communityService.isMobileSDK()) {
            const evt = new ShowToastEvent({
                title: '',
                message: 'Opening this link is only supported using the web browser experience',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            this.isUploadModalOpen = true;
        }
    }
    //close model for refresh
    closeUploadModal() {
        if (this.progress == 100 || this.progress == 0) {
            if (this.progress == 100) {
                this.deleteFiles();
            }

            this.selectedStudy = '';
            this.template.querySelector('.fileInput').value = null;
            this.template.querySelector('.fileInput').disabled = false;
            this.fileName = '';
            this.progress = 0;
            this.progressWidth = 'width :0%';
            this.base = 1;
            this.progressMultiplier = 0;
            this.isUploadModalOpen = false;
        }
    }

    progress = 0;
    progressWidth = 'width :0%';
    base = 1;
    progressMultiplier = 0;
    fileName = '';
    filesUploaded = [];
    isLoading = false;
    fileSize;
    fileId = '';
    csvData = '';
    totalRecs = 0;
    validFile = true;
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            event.target.disabled = true;
            this.fileName = event.target.files[0].name;
            this.progress = 0;
            this.progressWidth = 'width :0%';
            this.base = 1;
            this.totalRecs = 0;
            this.progressMultiplier = 0;
            this.saveFile();
        }
    }

    saveFile() {
        var fileCon = this.filesUploaded[0];
        this.fileSize = this.formatBytes(fileCon.size, 2);
        if (fileCon.size > MAX_FILE_SIZE) {
            let message =
                'File size cannot exceed ' +
                MAX_FILE_SIZE +
                ' bytes.\n' +
                'Selected file size: ' +
                fileCon.size;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                })
            );
            this.template.querySelector('.fileInput').value = null;
            this.template.querySelector('.fileInput').disabled = false;
            this.fileName = '';
            return;
        }
        if (
            this.fileName.split('.')[1] != 'csv' &&
            this.fileName.split('.')[1] != 'xlsx' &&
            this.fileName.split('.')[1] != 'xls'
        ) {
            let message = this.BulkImport_Please_upload_only_csv_xlsx_or_xls_format_files;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                })
            );
            this.template.querySelector('.fileInput').value = null;
            this.template.querySelector('.fileInput').disabled = false;
            this.fileName = '';
            return;
        }

        //file first two rows

        this.validFile = true;
        var row1 = [];
        row1.push('Patient ID');
        row1.push('First Name');
        row1.push('Patient Middle Name Initial');
        row1.push('Last Name');
        row1.push('Patient Sex');
        row1.push('Email Address');
        row1.push('YOB');
        row1.push('Legal Status of Patient');
        row1.push('Patient Auth.');
        row1.push('Country');
        row1.push('State/Province');
        row1.push('Phone number');
        row1.push('Patient  Phone Type');
        row1.push('Patient Alternative Phone');
        row1.push('Patient Alt. Phone Type');
        row1.push('Primary Delegate First Name');
        row1.push('Primary Delegate Last Name');
        row1.push('Primary Delegate Email');
        row1.push('Primary Delegate Phone Number');
        row1.push('Primary Delegate Phone Type');
        row1.push('Primary Delegate YOB');
        row1.push('Legal Status of Primary Delegate');

        var row2 = [];
        row2.push('ID entered by the RP');
        row2.push(
            'Capitalized as you want the name to appear in the platform.    Text. Considered personal information'
        );
        row2.push('May write out name or use intial with a period. Examples: Mary or M');
        row2.push('Text Considered personal information');
        row2.push('Enter spelled out as either:Female or Male');
        row2.push(
            'If patient is a minor the email address will not be stored.          youremail@yourdomain.com Considered personal information'
        );
        row2.push('YOB of the patient in YYYY or blank when not filled');
        row2.push(
            '"""I attest that patient is of the age of legal majority"".   Options: Yes/No            Whether the attestation from RP to indicate whether this patient is above the legal age or not."'
        );
        row2.push(
            '"""My patient, and/or patient\'s legal guardian if applicable, agrees to share their information with a study team, and to be contacted at the telephone number(s) and email they have provided, and via automated dialing, and/or artificial or pre-recorded voice, to schedule study appointments and keep them updated with important study-related information.  Their consent is not required as a condition of purchasing any property, goods, or services.""  Options: Yes/No. To indicate whether the RP has the authorization from the patient or blank when not filled. Required Only if the file has Personal Information"'
        );
        row2.push(
            '"Defaulted to the RP\'s country if not filled. If the country is changed, then age of legal majority check has to be done depending on the new value. Spell out the country name if entering it, example: United States"'
        );
        row2.push("Defaulted to RP's State/Province if not filled.");
        row2.push(
            "For a minor patient enter the participant delegate's phone number.       Format per country 919-555-1212"
        );
        row2.push('Enter one of these values: Home         Work        Mobile');
        row2.push('Format per country 919-555-1212');
        row2.push('Enter one of these values: Home         Work        Mobile');
        row2.push(
            'Mandatory for a minor patient.      (when Legal Status of participant is No) Text'
        );
        row2.push('Mandatory for a minor patient. (when Legal Status of participant is No) Text');
        row2.push('Mandatory for a minor participant.           youremail@yourdomain.com');
        row2.push('Format per country 919-555-1212.');
        row2.push('Enter one of these values: Home        Work      Mobile');
        row2.push('YYYY (formatted as text) ex. 1987');
        row2.push(
            '"""I attest that primary delegate or legal guardian is of the age of legal majority"".  Mandatory for a minor participant.  Enter Yes to attest the delegate is of/over the age of legal majority"'
        );
        // I attest that primary delegate or legal guardian is of the age of legal majority.
        this.progressWidth = 'width :8%';
        this.progress = 8;
        this.base = Math.floor((CHUNK_SIZE / fileCon.size) * 100);

        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(fileCon, fileContents);
        };
        var reader2 = new FileReader();
        reader2.onload = function (e) {
            try {
                var binary = '';
                var bytes = new Uint8Array(e.target.result);
                var length = bytes.byteLength;

                for (var i = 0; i < length; i++) {
                    binary += String.fromCharCode(bytes[i]);
                }
                var workbook = XLSX.read(binary, { type: 'binary', raw: true });
                var sheet_name_list = workbook.SheetNames;
                var fileData = String(XLSX.utils.sheet_to_csv(workbook.Sheets[sheet_name_list[0]]));
                self.csvData = fileData;
                var csvRows = fileData.split('\n');
                self.totalRecs = csvRows.length - 2;
                if (!(csvRows[0] == row1.join() && csvRows[1] == row2.join())) {
                    row1.push('Validation Errors');
                    row2.push('');
                    if (!(csvRows[0] == row1.join() && csvRows[1] == row2.join())) {
                        self.validFile = false;
                    }
                }
            } catch (e) {
                console.log('error' + e.message);
            }
        };
        reader2.readAsArrayBuffer(fileCon);
        reader.readAsDataURL(fileCon);
    }

    upload(file, fileContents) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
        this.uploadChunk(file, fileContents, fromPos, toPos, '');
    }

    uploadChunk(file, fileContents, fromPos, toPos, attachId) {
        this.isLoading = true;
        var chunk = fileContents.substring(fromPos, toPos);

        saveTheChunkFile({
            parentId: this.userConID,
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: attachId
        })
            .then((result) => {
                this.fileId = result;
                attachId = result;
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
                if (fromPos < toPos) {
                    this.progressMultiplier++;
                    if (this.base * this.progressMultiplier < 100) {
                        this.progress = this.base * this.progressMultiplier;
                    } else {
                        this.progress = 99;
                    }
                    this.progressWidth = 'width :' + this.progress + '%';
                    this.uploadChunk(file, fileContents, fromPos, toPos, attachId);
                } else {
                    if (!this.validFile) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: this.BulkImport_Uploaded_format,
                                variant: 'error'
                            })
                        );
                        this.deleteFiles();
                        this.isLoading = false;
                    } else if (this.totalRecs > 500) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: this.BulkImport_Total_number,
                                variant: 'error'
                            })
                        );
                        this.deleteFiles();
                        this.isLoading = false;
                    } else {
                        this.progress = 100;
                        this.progressWidth =
                            'width :' + this.progress + '%;background-color: #00C221;';
                        this.isLoading = false;
                    }
                }
            })
            .catch((error) => {
                console.error('Error: ', error);
            })
            .finally(() => {});
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    selectedStudy = '';

    get enableDel() {
        return this.progress == 100;
    }

    get enableImport() {
        return this.progress == 100 && this.selectedStudy != '';
    }

    get fileRemaining() {
        var fs = this.fileSize.split(' ');
        var fu = ((fs[0] * this.progress) / 100).toFixed(2);
        if (fs[0] / fu == 1) {
            return this.fileSize;
        } else {
            return fu + ' ' + fs[1] + ' of ' + this.fileSize;
        }
    }

    selectStudy(event) {
        this.selectedStudy = event.target.value;
    }

    deleteFiles() {
        deleteFile({
            fileId: this.fileId
        })
            .then((result) => {
                this.template.querySelector('.fileInput').value = null;
                this.template.querySelector('.fileInput').disabled = false;
                this.fileName = '';
                this.progress = 0;
                this.progressWidth = 'width :0%';
                this.base = 1;
                this.progressMultiplier = 0;
            })
            .catch((error) => {
                console.error('Error: ', error);
            })
            .finally(() => {});
    }

    importRec() {
        this.template.querySelector('.fileInput').value = null;
        this.template.querySelector('.fileInput').disabled = false;
        this.fileName = '';
        this.progress = 0;
        this.progressWidth = 'width :0%';
        this.base = 1;
        this.progressMultiplier = 0;
        this.isUploadModalOpen = false;
        this.inProgress = true;
        this.completed = false;
        processvalidateFile({
            fileID: this.fileId,
            studyID: this.selectedStudy,
            rpState: this.rpState,
            rpCountry: this.rpCountry,
            csvData: this.csvData,
            delegateId: this.userConID
        }).then((result) => {
            this.selectedStudy = '';
            this.inProgress = false;
            this.filesLoaded = false;
            this.getDetailsApex();
            this.completed = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message:
                        'Your file was processed successfully. Please check to see if there are any errors in the Rejected table',
                    variant: 'success'
                })
            );
        });
    }

    instructionUpdate(event) {
        this.showInstruction = !event.target.checked;
    }

    updateShowInstructValue() {
        getShowInstructValue({
            flag: this.showInstruction
        }).then((result) => {
            this.isInstrModalOpen = false;
        });
    }

    //mobile
    showButtons = false;

    toggleButtons() {
        this.showButtons = !this.showButtons;
    }
}
