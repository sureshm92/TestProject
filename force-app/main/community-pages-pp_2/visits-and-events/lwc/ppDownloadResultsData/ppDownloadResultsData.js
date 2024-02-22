import { LightningElement, api } from 'lwc';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import Download_PP from '@salesforce/label/c.Download_PP';
import Open_In_New_Tab_PP from '@salesforce/label/c.Open_In_New_Tab_PP';
import myResults from '@salesforce/label/c.Visit_Results_Dashboard_My_Results';
import Download_In_Progress_PP from '@salesforce/label/c.Download_In_Progress_PP';
import Visit_Results_Disclaimer_Past_Studies from '@salesforce/label/c.Visit_Results_Disclaimer_Past_Studies';
import generateVisitResult from '@salesforce/apex/ppPastStudiesTabUtility.generateVisitResult';
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
    isTab=false;
    isLandscape = false;
    label = {
        PP_Download_Results_Data,
        Open_In_New_Tab_PP,
        Download_PP,
        Download_In_Progress_PP,
        Visit_Results_Disclaimer_Past_Studies,
        myResults
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
        this.dummy = true;
        this.isTabletMenu();
        this.isIpadLandscape();
        window.addEventListener('orientationchange', this.onOrientationChange);
    }
    onOrientationChange = () => {
        this.isIpadLandscape();
        this.isTabletMenu();
    };
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
    get isPastStudies() {
        return this.alumniPeId != null ? true : false;
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

        if (
            event.currentTarget.name == 'download-res' ||
            event.currentTarget.name == 'download-res-past' ||
            event.currentTarget.name == 'download-res-mob' ||
            event.currentTarget.name == 'download-res-mob-past' ||
            event.currentTarget.name == 'download-res-tab' ||
            event.currentTarget.name == 'download-res-tab-past' ||
            event.currentTarget.dataset.name == 'download-vis-res'
        ) {
            this.template
                .querySelector('c-custom-toast-files-p-p')
                .showToast(
                    'success',
                    this.label.Download_In_Progress_PP,
                    'utility:download',
                    10000
                );
            anchorEle = this.isDesktop
                ? this.template.querySelectorAll('.download-results')
                : this.template.querySelectorAll('.download-report');
        }
        if (communityService.isMobileSDK()) {
            this.downloadResult();            
        } else {
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
                if (event.currentTarget.dataset.name == 'view-res') {
                    window.open(url);
                } else if (
                    event.currentTarget.name == 'download-res' ||
                    event.currentTarget.name == 'download-res-mob' ||
                    event.currentTarget.name == 'download-res-tab' ||
                    event.currentTarget.dataset.name == 'download-vis-res'
                ) {
                    if(this.isTab || this.isLandscape){
                        window.open(url);
                    }else{
                        anchorEle[0].setAttribute('href', url);
                        if (this.isDesktop) {
                            anchorEle[0].click();
                        }
                    }
                }
            } else {
                let url =
                    '/pp/apex/PatientVisitReportPage?peId=' +
                    this.alumniPeId +
                    '&isRTL=' +
                    this.isRTL;
                if (event.currentTarget.name == 'view-res-past') {
                    window.open(url);
                } else if (
                    event.currentTarget.name == 'download-res-past' ||
                    event.currentTarget.name == 'download-res-mob' ||
                    event.currentTarget.name == 'download-res-mob-past' ||
                    event.currentTarget.name == 'download-res-tab-past'
                ) {
                    anchorEle[0].setAttribute('href', url);
                    anchorEle[0].click(function (event) {
                        event.stopPropagation();
                    });
                }
            }
        }
    }

    toggleElement() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.toggle('active');
    }
    removeElementFocus() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.remove('active');
    }

    isTabletMenu() {
        //alert('coming');
        let orientation = screen.orientation.type;
        let portrait = true;
        if (orientation === 'landscape-primary') {
            portrait = false;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && portrait) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isTab = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isTab = true;
                return true;
            }
        } else {
            this.isTab = false;
        }
        return false;
    }
    isIpadLandscape() {
        let orientation = screen.orientation.type;
        let landscape = false;
        if (orientation === 'landscape-primary') {
            landscape = true;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && landscape) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isLandscape = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isLandscape = true;
                return true;
            }
        }
        this.isLandscape = false;
        return false;
}
    downloadInProgress =false;
    downloadResult(){
        var pvName = this.patientVisitNam;
        if(!this.patientVisitNam){
            pvName = 'undefined';
        }
        if(!this.downloadInProgress){
            this.downloadInProgress = true;
            generateVisitResult({
                peId: this.peId,
                isRTL: this.isRTL,
                patientVisitNam: pvName,
                patientVisId: this.patientVisitId
            })
            .then((result) => {
                window.open('../sfc/servlet.shepherd/version/download/' + result);
                this.downloadInProgress = false;
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
    }
}