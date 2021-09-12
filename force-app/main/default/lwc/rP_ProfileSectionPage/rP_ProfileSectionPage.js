import { LightningElement, wire, track, api } from 'lwc';
import updateMRRStatus from '@salesforce/apex/RPRecordReviewLogController.setMRRStatus';
import getSelectedPeDetails from '@salesforce/apex/RPRecordReviewLogController.getSelectedPeDetails';
import excludeStatus from '@salesforce/apex/RPRecordReviewLogController.changeStatusToExcludeFromReferring';
import includeStatus from '@salesforce/apex/RPRecordReviewLogController.undoChangeStatusToExcludeFromReferring';
import community_icon from '@salesforce/resourceUrl/rr_community_icons'
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class RP_ProfileSectionPage extends NavigationMixin(LightningElement) {
    @api usermode; 
    @api delegateid; 
    @api isLoading; 
    @track medicalReview = false;
    @api peId; 
    @api ctpId;
    @api peRecordList =[];
    @api error;
    @api icon_Url_LegalStatus;
    @api isLegalStatus;
    @api emptyLegalStatus = false;
    @api icon_Url_PatientAuthStatus;
    @api ispatientAuthStatus;
    @api emptyPatientAuthStatus = false;
    @api icon_Url_MedicalReviewStatus;
    @api isMedicalReviewStatus;
    @api emptyMedicalReviewStatus = false;
    @api icon_Url_PreEligibilityStatus;
    @api isPreEligibilityStatus =false;
    @api emptyPreEligibilityStatus = false;
    @track apexRefreshList = [];
    referbuttonShow = false;
    @api state;
    @api referbuttonDisable = false;
    @api medicalreviewConfigured = false;
    @api gizmosrc='';
    
    @api showInclude = false;
    @api showExclude = false;
    @api showMRR = false;
    @api showRefer = false;

    showmedicalreview() {
        this.medicalReview = !this.medicalReview; 
       this.showMRR = !this.showMRR;
    }

    excludepatient(){
        this.isLoading = true;
        excludeStatus({participantEnrollmentId: this.peId})
        .then((result) => { 
            console.log('success');
            refreshApex(this.apexRefreshList);
            this.dispatchEvent(new CustomEvent("refreshpatienttabchange"));
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);
        })
        .finally(() => {
            this.isLoading = false;
            eval("$A.get('e.force:refreshView').fire();");
        })
    }
    includepatient(){
        this.isLoading = true;
        includeStatus({participantEnrollmentId: this.peId})
        .then((result) => { console.log('success');
        refreshApex(this.apexRefreshList);
            this.dispatchEvent(new CustomEvent("refreshpatienttabchange"));
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);

        })
        .finally(() => {
            this.isLoading = false;
        })
    }

    doRedirectToReferPatient() {
       console.log('Redirect');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'referring'
            },
            state: {
                'peid': this.peId,
                'id' : this.ctpId,
                'patientVeiwRedirection':true,
               }
           });
    }

    @api
    handleEventChange(event){
        this.isLoading = true;
        var status;
        if(event.detail.result == true){
             status = 'Pass';
        }else{
            status = 'Fail';
        }
        this.medicalReview = false;

        updateMRRStatus({ peId: this.peId, status: status, surveyGizmoData:event.detail.gizmoData })
        .then((result) => {
            console.log(result); console.log('success');
            refreshApex(this.peRecordList);  
            this.checkMedicalReviewStatus(status);
            this.isLoading = false;
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);

        });
    }

    connectedCallback(){
        this.isLoading = true;
        getSelectedPeDetails({peId: this.peId,delegateId: this.delegateid ,userMode: this.usermode})
           .then(result => {
           this.peRecordList = result;
           this.checkLegalStatus(this.peRecordList[0].peRecord.Legal_Status__c);
           this.checkPatientAuthStatus(this.peRecordList[0].peRecord.Patient_Auth__c);
           if(this.peRecordList[0].peRecord.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c != undefined){
               this.medicalreviewConfigured = true;
               this.gizmosrc = this.peRecordList[0].peRecord.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c;
          }else{
               this.medicalreviewConfigured = false;
          }
          
           this.checkMedicalReviewStatus(this.peRecordList[0].peRecord.Medical_Record_Review_Status__c);
           this.checkPrescreeningStatus(this.peRecordList[0].peRecord.Pre_screening_Status__c);
           this.error = undefined;
           this.states = this.peRecordList[0].statesByCountryMap[this.peRecordList[0].peRecord.Country__c];
           if(this.peRecordList[0].peRecord.Participant_Status__c == 'Excluded from Referring'){
                this.showInclude = true;
                this.showExclude = false;
                this.showRefer = false;
                this.showMRR = false;
            }else{
                this.showInclude = false;
                this.showExclude = true;
            }
           if(this.peRecordList[0].accessLevel == "Level 2"){
               this.referbuttonDisable = true;
           }else{
               this.referbuttonDisable = false;
           }
           this.isLoading = false;
           })
           .catch(error => {
               this.error = error;
               console.log(JSON.stringify(error));
               this.peRecordList = undefined;
               this.isLoading = false;   
               
           });
    }

    checkLegalStatus(legalStatus) {
        if(legalStatus == 'Yes'){
            this.icon_Url_LegalStatus = community_icon + '/checkGreen.svg';
            this.legalStatus = true;
            this.emptyLegalStatus = false;
        } 
        else if(legalStatus == 'No'){
            this.icon_Url_LegalStatus = community_icon + '/close.svg';
            this.isLegalStatus = false;
            this.emptyLegalStatus = false;
        } 
        else {
            this.emptyLegalStatus = true;
        }
    }

    checkPatientAuthStatus(patientAuthStatus) {
        if(patientAuthStatus == 'Yes'){
            this.icon_Url_PatientAuthStatus = community_icon + '/checkGreen.svg';
            this.ispatientAuthStatus = true;
            this.emptyPatientAuthStatus = false;
        } 
        else if(patientAuthStatus == 'No'){
            this.icon_Url_PatientAuthStatus = community_icon + '/close.svg';
            this.ispatientAuthStatus = false;
            this.emptyPatientAuthStatus = false;
        } 
        else {
            this.emptyPatientAuthStatus = true;
        }
    }

    checkMedicalReviewStatus(medicalReviewStatus) {
        if(this.medicalreviewConfigured){
            if(medicalReviewStatus == 'Pass'){
                this.icon_Url_MedicalReviewStatus = community_icon + '/checkGreen.svg';
                this.isMedicalReviewStatus = true;
                this.emptyMedicalReviewStatus = false;
                this.showRefer = true;
                this.showMRR = false;
            } 
            else if(medicalReviewStatus == 'Fail'){
                this.icon_Url_MedicalReviewStatus = community_icon + '/close.svg';
                this.isMedicalReviewStatus = false;
                this.emptyMedicalReviewStatus = false;
                this.showRefer = true;
                this.showMRR = false;
            } 
            else if(medicalReviewStatus == undefined){
                this.emptyMedicalReviewStatus = true;
                this.showRefer = false;
                this.showMRR = true; 
            }
        }
        else{
            this.showRefer = false;
            this.showMRR = false;
        }
    }

    checkPrescreeningStatus(prescreeningStatus) {
        
        if(prescreeningStatus == 'Pass'){
            this.icon_Url_PreEligibilityStatus = community_icon + '/checkGreen.svg';
            this.isPreEligibilityStatus = true;
            this.emptyPreEligibilityStatus = false;
        } 
        else if(prescreeningStatus == 'Fail'){
            this.icon_Url_PreEligibilityStatus = community_icon + '/close.svg';
            this.isPreEligibilityStatus = false;
            this.emptyPreEligibilityStatus = false;
        } 
        else {
            this.emptyPreEligibilityStatus = true;
        }
    }

    handlePatientTabChange(event) {
        refreshApex(this.apexRefreshList);
    }
}