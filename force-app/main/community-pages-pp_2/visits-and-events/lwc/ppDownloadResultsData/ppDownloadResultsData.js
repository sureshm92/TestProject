import { LightningElement, api } from 'lwc';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import getBase64fromVisitSummaryReportPage_Modified from '@salesforce/apex/ModifiedVisitReportContainerRemote.getBase64fromVisitSummaryReportPage_Modified';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppDownloadResultsDataMobile.html';
import tabletTemplate from './ppDownloadResultsDataTablet.html';
import desktopTemplate from './ppDownloadResultsData.html';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import checkifPrimary from '@salesforce/apex/ppFileUploadController.checkifPrimary';

export default class PpDownloadResultsData extends LightningElement {
    peId;
    isRTL;
    userDetails;
    @api alumniPeId;
    @api patientVisitNam;
    @api patientVisitId;
    showDownloadResults;
    label = {
        PP_Download_Results_Data
    };

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
    generateReport() {
        if (!this.isDesktop) {
            getBase64fromVisitSummaryReportPage_Modified({
                peId: this.peId,
                isRTL: this.isRTL,
                patientVisitNam: this.patientVisitNam,
                patientVisId: this.patientVisitId
            })
                .then((returnValue) => {
                    communityService.navigateToPage('mobile-pdf-viewer?pdfData=' + returnValue);
                })
                .catch((error) => {
                    console.error('Error occured during report generation', error.message, 'error');
                });
        }

        if (this.patientVisitId != null) {
            window.open(
                '/pp/apex/PatientVisitReportPage?peId=' +
                    this.peId +
                    '&isRTL=' +
                    this.isRTL +
                    '&patientVisitNam=' +
                    this.patientVisitNam +
                    '&patientVisitId=' +
                    this.patientVisitId
            );
        } else {
            window.open(
                '/pp/apex/PatientVisitReportPage?peId=' + this.alumniPeId + '&isRTL=' + this.isRTL
            );
        }
    }
}
