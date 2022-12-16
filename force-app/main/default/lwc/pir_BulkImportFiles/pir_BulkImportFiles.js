import { LightningElement, wire, track, api } from "lwc";
import bulkicons from '@salesforce/resourceUrl/bulkicons';
import { CurrentPageReference } from 'lightning/navigation';
import DownloadParticipantTemplate from '@salesforce/resourceUrl/PARTICIPANTS_TEMPLATE';
import AllStudy from "@salesforce/label/c.PIR_All_Study";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AllStudySite from "@salesforce/label/c.PIR_All_Study_Site";
import RH_BulkImportInst from "@salesforce/label/c.RH_BulkImportInst";
import RH_FileTemplate from "@salesforce/label/c.RH_FileTemplate";
import RH_ImportInformation from "@salesforce/label/c.RH_ImportInformation";
import RH_ClickImport from "@salesforce/label/c.RH_ClickImport";
import RH_SelectStudy_SIte from "@salesforce/label/c.RH_SelectStudy_SIte";
import RH_File from "@salesforce/label/c.RH_File";
import RH_InformationSharing from "@salesforce/label/c.RH_InformationSharing";
import RH_ChoosePP from "@salesforce/label/c.RH_ChoosePP";
import BTN_Close from "@salesforce/label/c.BTN_Close";
import RH_ClickImportButton from "@salesforce/label/c.RH_ClickImportButton";
import RH_UploadResult from "@salesforce/label/c.RH_UploadResult";
import RH_AllRecords from "@salesforce/label/c.RH_AllRecords";
import RH_RejectedRecords from "@salesforce/label/c.RH_RejectedRecords";
import RH_DownloadIcon from "@salesforce/label/c.RH_DownloadIcon";
import PIR_Download from "@salesforce/label/c.PIR_Download";
import BulkImport_Actions from "@salesforce/label/c.BulkImport_Actions";
import RH_ValidationError from "@salesforce/label/c.RH_ValidationError";
import RH_ShowLanding from "@salesforce/label/c.RH_ShowLanding";
import RH_InputChanges from "@salesforce/label/c.RH_InputChanges";
import RH_RepeatSteps from "@salesforce/label/c.RH_RepeatSteps";
import RH_ImportSuccess from "@salesforce/label/c.RH_ImportSuccess";
import BulkImport_Instructions from "@salesforce/label/c.BulkImport_Instructions";
import RH_ImportNoRecords from "@salesforce/label/c.RH_ImportNoRecords";
import RH_BulkImportFiles from "@salesforce/label/c.RH_BulkImportFiles";
import RH_FileImport from "@salesforce/label/c.RH_FileImport";
import RH_FileImportProgress from "@salesforce/label/c.RH_FileImportProgress";
import BulkImport_File_Template from "@salesforce/label/c.BulkImport_File_Template";
import PIR_Import_Participants from "@salesforce/label/c.PIR_Import_Participants";
import BulkImport_File_Name from "@salesforce/label/c.BulkImport_File_Name";
import BulkImport_Initial_Total_Records from "@salesforce/label/c.BulkImport_Initial_Total_Records";
import BulkImport_Accepted from "@salesforce/label/c.BulkImport_Accepted";
import BulkImport_Rejected from "@salesforce/label/c.BulkImport_Rejected";
import BulkImport_Uploaded_By from "@salesforce/label/c.BulkImport_Uploaded_By";
import BulkImport_Uploaded_On from "@salesforce/label/c.BulkImport_Uploaded_On";
import BulkImport_Ok from "@salesforce/label/c.BulkImport_Ok";
import Bulk_Actions from "@salesforce/label/c.Bulk_Actions";
import getShowInstructValue from '@salesforce/apex/PIR_BulkImportController.getShowInstructValue';
import getInstruction from '@salesforce/apex/PIR_BulkImportController.getInstruction';
import getBulkImportHistoryInProgress from '@salesforce/apex/PIR_BulkImportController.getBulkImportHistoryInProgress';
import getBulkImportHistoryCompleted from '@salesforce/apex/PIR_BulkImportController.getBulkImportHistoryCompleted';
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
export default class Pir_BulkImportFiles extends LightningElement {
    instructionsSvgURL = bulkicons + '/instructions.svg';
    downloadSvgURL = bulkicons + '/Download.svg';
    impotrtSvgURL = bulkicons + '/icon.svg';
    fileicon = bulkicons + '/file-xls.svg';
    importParticipant = false;

    bulkImportList;
    bulkHistoryDataCompleted;
    bulkHistoryDataInProgress;
    noRecords = false;
    saving = true;
    totalRecord;
    currentPageReference = null;
    urlStateParameters = null;
    urlmyStudies = null;
    urlmyParticipants = null;
    urltrialId = null;
    urlsiteId = null;
    @api myStudiesPg = false;
    isInstrModalOpen = false;
    showInstruction = false;
    batchStartIntervalId;
    currentBatchStatus;
    BatchReturnValue;
    @api isBulkImportHistoryPage = false;
    inProgressData = false;
    @api stopSpinner = false;
    isSpinnerRunning = false;
    @api pageNumber = 1;
    @api getStudy;
    @api getStudySite = [];
    @api studylist;
    siteAccessLevels;
    studyToStudySite;
    studysiteaccess = false;
    selectedSite = '';
    studySiteList;
    selectedStudy = '';
    getimportids = [];
    getTotalCount;
    showToastSuccess = false;
    oldMap = new Map();
    inProgressOldDataid = [];
    successBoolean = false;

    label = {
        AllStudy,
        AllStudySite,
        RH_BulkImportInst,
        RH_FileTemplate,
        RH_ImportInformation,
        RH_ClickImport,
        RH_SelectStudy_SIte,
        RH_File,
        RH_InformationSharing,
        RH_ChoosePP,
        RH_ClickImportButton,
        RH_UploadResult,
        RH_AllRecords,
        RH_RejectedRecords,
        RH_DownloadIcon,
        RH_ValidationError,
        RH_InputChanges,
        RH_RepeatSteps,
        BulkImport_Instructions,
        RH_ImportNoRecords,
        RH_BulkImportFiles,
        RH_FileImport,
        BulkImport_Actions,
        RH_FileImportProgress,
        BulkImport_Instructions,
        BulkImport_File_Template,
        PIR_Import_Participants,
        BulkImport_File_Name,
        BulkImport_Initial_Total_Records,
        BulkImport_Accepted,
        BulkImport_Rejected,
        BulkImport_Uploaded_By,
        BulkImport_Uploaded_On,
        Bulk_Actions,
        PIR_Download,
        BTN_Close,
        RH_ShowLanding,
        RH_ImportSuccess,
        BulkImport_Ok,
    };
    downloadTemplate = DownloadParticipantTemplate;

    get dontshowInstruction() {
        return !this.showInstruction;
    }

    connectedCallback() {
        this.getStudySiteData();
        this.getInstructionData();
    }
    renderedCallback() {
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }
    navigateValue = '';
    setParametersBasedOnUrl() {
        this.urlmyStudies = this.urlStateParameters.myStudies || null;
        if (this.urlStateParameters.navigateFromComponent == 'BulkimportHistryPage' ||
            this.urlStateParameters.navigateFromComponent == 'MyStudiesBulk') {
            this.isBulkImportHistoryPage = true;
        }
        else {
            this.isBulkImportHistoryPage = false;
        }

        this.urlmyParticipants = this.urlStateParameters.myParticipants || null;
        this.urltrialId = this.urlStateParameters.trialId || null;
        this.urlsiteId = this.urlStateParameters.ssId || null;

        if (this.urlStateParameters.navigateFromComponent == 'MyStudiesBulk' || this.urlStateParameters.navigateFromComponent == 'MyStudies' || this.urlmyStudies) {
            this.navigateValue = "MyStudiesBulk";
        }
        else {
            this.navigateValue = "BulkimportHistryPage";
        }
        if (this.urlmyStudies) {
            this.myStudiesPg = true;
            this.selectedStudy = this.urltrialId;
            this.getStudySite = this.urlsiteId;
            this.pageNumber = 1;
            this.updateInProgressOldData();
        } else {
            this.myStudiesPg = false;
        }
    }

    getStudySiteData() {
        getStudyStudySiteDetails()
            .then(data => {
                var siteAccessLevels = data.siteAccessLevels;
                var ctpListNoAccess = [];
                var studySiteMap = data;
                var studylist;
                var studyToStudySite;
                ctpListNoAccess = data.ctpNoAccess;
                var k = 0; var a = 0;

                var accesslevels = Object.keys(siteAccessLevels).length;
                if (studySiteMap.ctpMap) {
                    var conts = studySiteMap.ctpMap;
                    let options = [];
                    options.push({ label: this.label.AllStudy, value: "All Study" });
                    var sites = studySiteMap.studySiteMap;
                    for (var key in conts) {
                        if (!ctpListNoAccess.includes(conts[key])) {
                            var temp = sites[conts[key]];
                            let z = 0;
                            for (var j in temp) {
                                if (accesslevels == 0) {
                                    z = z + 1;
                                    a = a + 1;
                                } else {
                                    var level = siteAccessLevels[temp[j].Id];
                                    if (level != 'Level 3' && level != 'Level 2') {
                                        z = z + 1;
                                        a = a + 1;
                                    }
                                }
                            }
                            if (z != 0) {
                                options.push({ label: key, value: conts[key] });
                                k = k + 1;
                            }
                        }
                    }
                    studylist = options;
                    if (studySiteMap.studySiteMap) {
                        studyToStudySite = studySiteMap.studySiteMap;
                    }
                }
                if (!this.myStudiesPg) {
                    if (k != 0 && a != 0) {
                        this.studylist = studylist;
                        this.siteAccessLevels = siteAccessLevels;
                        this.studyToStudySite = studyToStudySite;
                        this.studysiteaccess = true;
                        this.selectedStudy = this.studylist[0].value;
                        var picklist_Value;
                        picklist_Value = this.selectedStudy;
                        var accesslevels = Object.keys(this.siteAccessLevels).length;
                        var conts = this.studyToStudySite;
                        let options = [];
                        options.push({ label: this.label.AllStudySite, value: "All Study Site" });
                        var i = this.siteAccessLevels;
                        if (picklist_Value != "All Study") {
                            for (var key in conts) {
                                if (key == picklist_Value) {
                                    var temp = conts[key];
                                    for (var j in temp) {
                                        if (accesslevels == 0) {
                                            options.push({ label: temp[j].Name, value: temp[j].Id });
                                        } else {
                                            var level = this.siteAccessLevels[temp[j].Id];
                                            if (level != 'Level 3' && level != 'Level 2') {
                                                options.push({ label: temp[j].Name, value: temp[j].Id });
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            for (var key in conts) {
                                var temp = conts[key];
                                for (var j in temp) {
                                    if (accesslevels == 0) {
                                        options.push({ label: temp[j].Name, value: temp[j].Id });
                                    } else {
                                        var level = this.siteAccessLevels[temp[j].Id];
                                        if (level != 'Level 3' && level != 'Level 2') {
                                            options.push({ label: temp[j].Name, value: temp[j].Id });
                                        }
                                    }
                                }
                            }
                        }
                        this.studySiteList = options;
                        this.selectedSite = this.studySiteList[0].value;
                        this.studysiteaccess = false;
                        var getStudySiteList = [];
                        if (this.selectedSite != null && this.selectedSite == "All Study Site") {
                            for (var i = 1; i < this.studySiteList.length; i++) {
                                getStudySiteList.push(this.studySiteList[i].value);
                                this.getStudySite = getStudySiteList;
                            }
                        } else if (
                            this.selectedSite != null &&
                            this.selectedSite != "All Study Site"
                        ) {
                            this.getStudySite = this.selectedSite;
                        }

                    }
                }
                this.fetchData();
                this.getLatest();
            })
            .catch(error => {
                this.err = error;
                console.log('Error : ' + JSON.stringify(this.err));
                console.log('Error : ' + error.message);
            });



    }

    @api fetchData() {
        if (!this.stopSpinner) {
            this.saving = true;
            this.isSpinnerRunning = true;
        }
        getBulkImportHistoryCompleted({ getStudySite: this.getStudySite, pageNumber: this.pageNumber })
            .then(result => {
                this.bulkHistoryDataCompleted = result.bulkHistoryDataCompleted;
                this.totalRecord = result.totalCount;
                const selectEvent = new CustomEvent('gettotalrecord', {
                    detail: this.totalRecord
                });
                this.dispatchEvent(selectEvent);

                const selectEventnew = new CustomEvent('resetpagination', {
                    detail: ''
                });
                this.dispatchEvent(selectEventnew);
                if (result.bulkHistoryDataCompleted.length > 0) {
                    this.noRecords = false;
                    this.template.querySelectorAll(".nodata").forEach(function (L) {
                        L.classList.remove("table-width-nodata");
                    });
                }
                else {
                    this.template.querySelectorAll(".nodata").forEach(function (L) {
                        L.classList.add("table-width-nodata");
                    });
                    this.noRecords = true;
                }
                for (var i = 0; i < result.bulkHistoryDataCompleted.length; i++) {
                    if (result.bulkHistoryDataCompleted[i].Rejected_Records__c != '0') {
                        result.bulkHistoryDataCompleted[i].isRejected = true;
                    }
                    else {
                        result.bulkHistoryDataCompleted[i].isRejected = false;
                    }
                }

                if (this.isSpinnerRunning) {
                    this.saving = false;
                    this.isSpinnerRunning = false;
                    this.stopSpinner = true;
                }


            })
            .catch(error => {
                this.saving = true;
                this.err = error;
                console.log('Error : ' + JSON.stringify(this.err));
                console.log('Error : ' + error.message);
            });
        getBulkImportHistoryInProgress({ getStudySite: this.getStudySite })
            .then(result => {
                this.bulkHistoryDataInProgress = result;
                var conts = result;
                var newResultIds = [];

                for (var key in conts) {
                    newResultIds.push(conts[key].Id);
                }
                if (result.length > 0) {
                    this.inProgressData = true;
                    if (this.inProgressOldDataid == null || this.inProgressOldDataid == undefined || this.inProgressOldDataid.length == 0) {
                        for (var key in conts) {
                            this.inProgressOldDataid.push(conts[key].Id);

                        }

                    }
                    else {
                        var arrayLength = this.inProgressOldDataid.length;
                        for (var i = 0; i < arrayLength; i++) {
                            if (!newResultIds.includes(this.inProgressOldDataid[i])) {
                                this.isToast = true;

                            } else {
                            }
                            //Do something
                        }
                        this.inProgressOldDataid = newResultIds;

                    }

                }
                else {
                    this.inProgressData = false;

                }

                if (result.length == 0 && this.inProgressOldDataid.length != 0) {
                    this.successBoolean = true;
                    this.inProgressOldDataid = [];
                }

                if (this.isToast || this.successBoolean) {
                    this.showSuccessToast(this.label.RH_ImportSuccess);
                    this.isToast = false;
                    this.successBoolean = false;
                }


            })
            .catch(error => {
                this.saving = true;
                this.err = error;
                console.log('Error : ' + JSON.stringify(this.err));
                console.log('Error : ' + error.message);
            });

    }

    @api updateInProgressOldData() {
        this.inProgressOldDataid = [];
    }
    getInstructionData() {
        getInstruction()
            .then(result => {
                this.isInstrModalOpen = false;
                this.showInstruction = false;
                if (!this.isBulkImportHistoryPage) {
                    this.isInstrModalOpen = !result;
                    this.showInstruction = !result;
                }
            })
            .catch(error => {
                this.saving = true;
                this.err = error;
                console.log('Error : ' + JSON.stringify(this.err));
                console.log('Error : ' + error.message);
            });

    }
    getLatest() {
        this._interval = setInterval(() => {
            if (this.inProgressData) {
                this.fetchData();
            }
            console.log('>>callback fro  batch>>');
            if (!this.inProgressData) {
                clearInterval(this._interval);
                console.log('>>cleared');
                this.successBoolean = false;

            }

        }, 10000);
    }


    handleImportModal() {
        this.importParticipant = true;

    }

    handleImportParticipant() {
        this.importParticipant = false;
        this.isBulkImportHistoryPage = false;
    }
    openIntructModal() {
        this.isInstrModalOpen = true;
    }
    handleClose() {
        this.isInstrModalOpen = false;
    }
    instructionUpdate(event) {
        this.showInstruction = !event.target.checked;
    }
    updateShowInstructValue() {
        this.isBulkImportHistoryPage = false;
        getShowInstructValue({
            flag: !this.showInstruction
        }).then((result) => {
            this.isInstrModalOpen = false;
        });


    }
    showSuccessToast(messageRec) {
        const evt = new ShowToastEvent({
            title: 'Success Message',
            message: messageRec,
            variant: 'success',
            duration: 400,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


}
