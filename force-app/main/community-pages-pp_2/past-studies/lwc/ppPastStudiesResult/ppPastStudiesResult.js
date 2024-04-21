import { LightningElement, api } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PP_No_results_available from '@salesforce/label/c.PP_No_results_available';
import getResult from '@salesforce/apex/ppPastStudiesTabUtility.resultAvailable';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import Past_Studies_Result_Text from '@salesforce/label/c.Past_Studies_Result_Text';
import getBase64fromVisitSummaryReportPage_Modified from '@salesforce/apex/ModifiedVisitReportContainerRemote.getBase64fromVisitSummaryReportPage_Modified';
import generateVisitResult from '@salesforce/apex/ppPastStudiesTabUtility.generateVisitResult';
import Download_In_Progress_PP from '@salesforce/label/c.Download_In_Progress_PP';

export default class PpPastStudiesResult extends LightningElement {
    @api perid;
    @api studyid;
    isRTL;
    noResultsIcon = pp_icons + '/' + 'no-results.svg';
    downloadresulticon = pp_icons + '/' + 'downloadIcon.svg';
    loaded;
    resultsAvailable;
    label={ PP_No_results_available,
            PP_Download_Results_Data,
            Past_Studies_Result_Text,
            Download_In_Progress_PP
          };
    connectedCallback(){
        this.checkResults();
        this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
    } 
    checkResults(){
        getResult({
            perId: this.perid,
        })
        .then((result) => {
            this.loaded = true;
            this.resultsAvailable = result;
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    }
    openResult(){
        if (communityService.isMobileSDK()) {
            this.downloadResult();
        }
        else{
            window.open(
                '/pp/apex/PatientVisitReportPage?peId=' + this.perid + '&isRTL=' + this.isRTL
            );
        }
    }
    
    downloadInProgress =false;
    downloadResult(){
        this.template
            .querySelector('c-custom-toast-files-p-p')
            .showToast(
                'success',
                this.label.Download_In_Progress_PP,
                'utility:download',
                10000
            );
        if(!this.downloadInProgress){
            this.downloadInProgress = true;
            
            generateVisitResult({
                peId: this.perid,
                isRTL: this.isRTL,
                patientVisId : null,
                patientVisId : null
            })
            .then((result) => {
                this.downloadInProgress = false;
                window.open('../sfc/servlet.shepherd/version/download/' + result);
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
    }
}