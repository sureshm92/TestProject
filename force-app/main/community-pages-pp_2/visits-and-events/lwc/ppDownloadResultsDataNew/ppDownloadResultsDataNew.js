import { LightningElement, api } from 'lwc';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import Download_PP from '@salesforce/label/c.Download_PP';
import Open_In_New_Tab_PP from '@salesforce/label/c.Open_In_New_Tab_PP';
import Download_In_Progress_PP from '@salesforce/label/c.Download_In_Progress_PP';
import File_Opening_In_New_Tab_PP from '@salesforce/label/c.File_Opening_In_New_Tab_PP';
import getBase64fromVisitSummaryReportPage_Modified from '@salesforce/apex/ModifiedVisitReportContainerRemote.getBase64fromVisitSummaryReportPage_Modified';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppDownloadResultsDataMobileNew.html';
import tabletTemplate from './ppDownloadResultsDataTabletNew.html';
import desktopTemplate from './ppDownloadResultsDataNew.html';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import checkifPrimary from '@salesforce/apex/ppFileUploadController.checkifPrimary';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PpDownloadResultsDataNew extends LightningElement {
    peId;
    isRTL;
    userDetails;
    @api alumniPeId;
    @api patientVisitNam;
    @api patientVisitId;
    showDownloadResults;
    label = {
        PP_Download_Results_Data,
        Open_In_New_Tab_PP,
        Download_PP,
        Download_In_Progress_PP,
        File_Opening_In_New_Tab_PP
    };
    val = false;
    dummy;
    viewResults;
    connectedCallback() {
        this.userDetails = communityService.getLoggedInUserData();
        if (this.alumniPeId != null) {
            this.peId = this.alumniPeId;
        } else {
            this.peId = communityService.getParticipantData().pe.Id;
        }
        this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
        if (this.userDetails.Contact.userCommunityDelegateId__c != null) {
            this.checkifPrimaryDelegate();
        } else {
            this.showDownloadResults = true;
        }
        this.dummy = true;
    }

    renderedCallback() {
        if (this.alumniPeId != null) {
            this.peId = this.alumniPeId;
            if (this.userDetails.Contact.userCommunityDelegateId__c != null) {
                this.checkifPrimaryDelegate();
            } else {
                this.showDownloadResults = true;
            }
        }
    }
    @api
    loadData() {
        if (this.alumniPeId != null) {
            this.peId = this.alumniPeId;
            if (this.userDetails.Contact.userCommunityDelegateId__c != null) {
                this.checkifPrimaryDelegate();
            } else {
                this.showDownloadResults = true;
            }
        }
    }

    checkifPrimaryDelegate() {
        checkifPrimary({
            perID: this.peId,
            currentContactId: this.userDetails.ContactId
        })
            .then((result) => {
                this.showDownloadResults = result != null ? true : false;
            })
            .catch((error) => {
                console.error('Error: in checkifPrimary', error);
            });
    }
    render() {
        if (this.isDesktop) {
            return desktopTemplate;
        } else if (this.isMobile) {
            return mobileTemplate;
        } else {
            return tabletTemplate;
        }
    }
    get isDesktop() {
        return FORM_FACTOR == 'Large';
    }

    get isMobile() {
        return FORM_FACTOR == 'Small';
    }

    get isTablet() {
        return FORM_FACTOR == 'Medium';
    }

    generateReport(event) {
        let anchorEle = '';
        if (event.currentTarget.name == 'download-res') {
            this.template
                .querySelector('c-custom-toast-files-p-p')
                .showToast(
                    'success',
                    this.label.Download_In_Progress_PP,
                    'utility:download',
                    10000
                );
            anchorEle = this.template.querySelectorAll('.download-results');
        }

        if (this.patientVisitId != null) {
            let url =
                '/pp/apex/PatientVisitReportPage?peId=' +
                this.peId +
                '&isRTL=' +
                this.isRTL +
                '&patientVisitNam=' +
                this.patientVisitNam +
                '&patientVisitId=' +
                this.patientVisitId;
            if (event.currentTarget.name == 'view-res') {
                window.open(url);
            } else if (event.currentTarget.name == 'download-res') {
                anchorEle[0].setAttribute('href', url);
                anchorEle[0].click(function (event) {
                    event.stopPropagation();
                });
            }
        } else {
            anchorEle = this.template.querySelectorAll('.download-results');
            let url =
                '/pp/apex/PatientVisitReportPage?peId=' + this.alumniPeId + '&isRTL=' + this.isRTL;
            anchorEle[0].setAttribute('href', url);
            anchorEle[0].click(function (event) {
                event.stopPropagation();
            });
        }
        this.dummy = false;
    }
    generateReport1(event) {
        let anchorEle = '';
        anchorEle = this.template.querySelectorAll('.download-results');
        this.showSuccessToast(this.label.Download_In_Progress_PP, 'message', 'success');
        if (this.patientVisitId != null) {
            let url =
                '/pp/apex/PatientVisitReportPage?peId=' +
                this.peId +
                '&isRTL=' +
                this.isRTL +
                '&patientVisitNam=' +
                this.patientVisitNam +
                '&patientVisitId=' +
                this.patientVisitId;

            anchorEle[0].setAttribute('href', url);
            anchorEle[0].click(function (event) {
                event.stopPropagation();
            });
        } else {
            console.log('JJ 2');
            let url =
                '/pp/apex/PatientVisitReportPage?peId=' + this.alumniPeId + '&isRTL=' + this.isRTL;
            anchorEle[0].setAttribute('href', url);
            anchorEle[0].click(function (event) {
                event.stopPropagation();
            });
        }
        this.dummy = false;
    }
    toggleElement() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.toggle('active');
    }
    removeElementFocus() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.remove('active');
    }
}
