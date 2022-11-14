import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateMRRStatus from '@salesforce/apex/RPRecordReviewLogController.setMRRStatus';
import getSelectedPeDetails from '@salesforce/apex/RPRecordReviewLogController.getSelectedPeDetails';
import excludeStatus from '@salesforce/apex/RPRecordReviewLogController.changeStatusToExcludeFromReferring';
import includeStatus from '@salesforce/apex/RPRecordReviewLogController.undoChangeStatusToExcludeFromReferring';
import community_icon from '@salesforce/resourceUrl/rr_community_icons'
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import RH_RP_Exclude from '@salesforce/label/c.RH_RP_Exclude';
import RH_RP_Include from '@salesforce/label/c.RH_RP_Include';
import RH_RP_Exclude_From_Referring from '@salesforce/label/c.RH_RP_Exclude_From_Referring';
import RH_RP_Include_From_Referring from '@salesforce/label/c.RH_RP_Include_From_Referring';
import RH_RP_Medical_Review from '@salesforce/label/c.RH_RP_Medical_Review';
import RH_RP_Refer from '@salesforce/label/c.RH_RP_Refer';
import RH_RP_Study_Code from '@salesforce/label/c.RH_RP_Study_Code';
import RH_RP_Legal_Status from '@salesforce/label/c.RH_RP_Legal_Status';
import RH_RP_legal_status_attest from '@salesforce/label/c.RH_RP_legal_status_attest';
import RH_RP_Patient_Auth from '@salesforce/label/c.RH_RP_Patient_Auth';
import RH_RP_Patient_Auth_Help from '@salesforce/label/c.RH_RP_Patient_Auth_Help';
import RH_RP_Pre_Eligibility_Screening from '@salesforce/label/c.RH_RP_Pre_Eligibility_Screening';
import RH_RP_Added_On from '@salesforce/label/c.RH_RP_Added_On';
import RH_RP_N_A from '@salesforce/label/c.RH_RP_N_A';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import RH_RP_Exclude_Record from '@salesforce/label/c.RH_RP_Exclude_Record';
import RH_RP_exclude_this_patient from '@salesforce/label/c.RH_RP_exclude_this_patient';
import Cancel from '@salesforce/label/c.Cancel';
import BTN_OK from '@salesforce/label/c.BTN_OK';
import RH_RP_Include_Record from '@salesforce/label/c.RH_RP_Include_Record';
import RH_RP_want_to_include_patients from '@salesforce/label/c.RH_RP_want_to_include_patients';
import RH_RP_Excluded_Successfully from '@salesforce/label/c.RH_RP_Excluded_Successfully';
import RH_RP_has_been_excluded from '@salesforce/label/c.RH_RP_has_been_excluded';
import RH_RP_included_successfully from '@salesforce/label/c.RH_RP_included_successfully';
import RH_RP_has_been_included from '@salesforce/label/c.RH_RP_has_been_included';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import RH_RP_Outreach_Email from '@salesforce/label/c.RH_RP_Outreach_Email';
import { loadScript } from 'lightning/platformResourceLoader';
import RH_RP_Patient from '@salesforce/label/c.Patient';
import RH_RP_Primary_Delegate from '@salesforce/label/c.Primary_Delegate';
import RH_RP_Notes from '@salesforce/label/c.Notes';

export default class RP_ProfileSectionPage extends NavigationMixin(LightningElement) {
    @api usermode;
    @api delegateid;
    @api isLoading;
    @track medicalReview = false;
    @api peId;
    @api ctpId;
    @api peRecordList = [];
    @api delegatepeRecordList = [];
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
    @api isPreEligibilityStatus = false;
    @api emptyPreEligibilityStatus = false;
    @track apexRefreshList = [];
    referbuttonShow = false;
    @api state;
    @api referbuttonDisable = false;
    @api medicalreviewConfigured = false;
    @api gizmosrc = '';
    @api showInclude = false;
    @api showExclude = false;
    @api showMRR = false;
    @api showRefer = false;
    @api disabledSaveButton = false;
    @api isaccessLevelthree = false;
    disabledOutreachButton = false;
    @api isRTL;
    @api isCountryus=false;
    label = {
        RH_RP_Primary_Delegate,
        RH_RP_Patient,
        RH_RP_Notes,
        RH_RP_Exclude,
        RH_RP_Include,
        RH_RP_Exclude_From_Referring,
        RH_RP_Include_From_Referring,
        RH_RP_Medical_Review,
        RH_RP_Refer,
        RH_RP_Study_Code,
        RH_RP_Legal_Status,
        RH_RP_legal_status_attest,
        RH_RP_Patient_Auth,
        RH_RP_Patient_Auth_Help,
        RH_RP_Pre_Eligibility_Screening,
        RH_RP_Added_On,
        RH_RP_N_A,
        BTN_Close,
        RH_RP_Exclude_Record,
        RH_RP_exclude_this_patient,
        Cancel,
        BTN_OK,
        RH_RP_Include_Record,
        RH_RP_want_to_include_patients,
        RH_RP_Excluded_Successfully,
        RH_RP_has_been_excluded,
        RH_RP_included_successfully,
        RH_RP_has_been_included,
        RH_RP_Outreach_Email
    };


    showmedicalreview() {
        this.medicalReview = !this.medicalReview;
        this.showMRR = !this.showMRR;
    }

    excludepatient() {
        this.disableButton = true;
        excludeStatus({ participantEnrollmentId: this.peId })
            .then((result) => {
                if (this.peRecordList[0].peRecord.Participant_Name__c == undefined) {
                    this.showSuccessToast(this.label.RH_RP_Excluded_Successfully);
                }
                else {
                    this.showSuccessToast(this.peRecordList[0].peRecord.Participant_Name__c + ' ' + this.label.RH_RP_has_been_excluded);
                }
                const selectedvalue = { peRecordList: this.peRecordList };
                const selectedEvent = new CustomEvent('includeexcluderefresh', { detail: selectedvalue });
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);

            })
            .finally(() => {
            })
    }
    includepatient() {
        this.disableButton = true;
        includeStatus({ participantEnrollmentId: this.peId })
            .then((result) => {
                if (this.peRecordList[0].peRecord.Participant_Name__c == undefined) {
                    this.showSuccessToast(this.label.RH_RP_included_successfully);
                }
                else {
                    this.showSuccessToast(this.peRecordList[0].peRecord.Participant_Name__c + ' ' + this.label.RH_RP_has_been_included);
                }

                const selectedvalue = { peRecordList: this.peRecordList };
                const selectedEvent = new CustomEvent('includeexcluderefresh', { detail: selectedvalue });
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);
            })
            .finally(() => {
            })
    }

    doRedirectToReferPatient() {
        var pathurl = {peId:this.peId, id:this.ctpId, patientVeiwRedirection:true};
        const selectedEvent = new CustomEvent('pgredirection', {
            detail : pathurl
        });
        this.dispatchEvent(selectedEvent);

        /**this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'referring'
            },
            state: {
                'peid': this.peId,
                'id': this.ctpId,
                'patientVeiwRedirection': true,
            }
        }); **/
    }

    @api
    handleEventChange(event) {
        this.isLoading = true;
        var status;
        if (event.detail.result == true) {
            status = 'Pass';
        } else {
            status = 'Fail';
        }
        this.medicalReview = false;

        updateMRRStatus({ 
            peId: this.peId, 
            status: status, 
            surveyGizmoData: event.detail.gizmoData,
            screenerId: this.apexRefreshList[0].mrrScreener.Id
        })
            .then((result) => {
                refreshApex(this.peRecordList);
                this.checkMedicalReviewStatus(status);
                this.isLoading = false;
            })
            .catch((error) => {
                this.errors = error;
                console.log(error);

            });
    }

    connectedCallback() {
        this.isLoading = true;
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.userMode = communityService.getUserMode();
                this.delegateId = communityService.getDelegateId();
            })
            .then(() => {
                this.getPEdetails();
            }).catch((error) => {
                console.log('Error: ' + error);
            });
    }

    getPEdetails() {
        getSelectedPeDetails({ peId: this.peId, delegateId: this.delegateid, userMode: this.usermode })
            .then(result => {
                this.apexRefreshList = result;
                this.peRecordList = result;
                this.delegatepeRecordList = result;

                this.checkLegalStatus(this.peRecordList[0].peRecord.Legal_Status__c);
                this.checkPatientAuthStatus(this.peRecordList[0].peRecord.Patient_Auth__c);


                if (this.peRecordList[0].peRecord.Patient_ID__c != undefined && this.peRecordList[0].peRecord.Participant_Name__c != undefined
                    && this.peRecordList[0].peRecord.YOB__c != undefined && this.peRecordList[0].peRecord.Patient_Auth__c != undefined
                    && this.peRecordList[0].peRecord.Participant_Surname__c != undefined
                    && this.peRecordList[0].peRecord.Participant_Surname__c != ''
                    && this.peRecordList[0].peRecord.Participant_Surname__c != null
                    && this.peRecordList[0].peRecord.Participant_Name__c != null
                    && this.peRecordList[0].peRecord.Participant_Name__c != ''
                    && this.peRecordList[0].peRecord.Patient_ID__c != ''
                    && this.peRecordList[0].peRecord.Patient_ID__c != null
                ) {
                    if (this.peRecordList[0].accessLevel == "Level 3") {
                        this.disabledSaveButton = true;
                    } else { this.disabledSaveButton = false; }
                }
                else {
                    this.disabledSaveButton = true;
                }

                if (this.peRecordList[0].mrrScreener && this.peRecordList[0].mrrScreener.Link_to_Pre_screening__c) {
                    this.medicalreviewConfigured = true;
                    this.gizmosrc = this.peRecordList[0].mrrScreener.Link_to_Pre_screening__c;
                } else {
                    this.medicalreviewConfigured = false;
                }

                if (!this.peRecordList[0].peRecord.Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c || this.peRecordList[0].peRecord.Outreach_Email_Status__c != undefined 
                    || this.peRecordList[0].peRecord.Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c == undefined || this.peRecordList[0].peRecord.Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c == undefined
                    || this.peRecordList[0].accessLevel == "Level 2" || this.peRecordList[0].accessLevel == "Level 3") {
                    this.disabledOutreachButton = true;
                } else {
                    this.disabledOutreachButton = false;
                }

                this.checkMedicalReviewStatus(this.peRecordList[0].mrrScreenerResponse ? this.peRecordList[0].mrrScreenerResponse.Status__c : undefined);
                this.checkPrescreeningStatus(this.peRecordList[0].prescreenerResponse ? this.peRecordList[0].prescreenerResponse.Status__c : undefined);
                this.error = undefined;
                this.states = this.peRecordList[0].statesByCountryMap[this.peRecordList[0].peRecord.Mailing_Country_Code__c];
                if (this.peRecordList[0].peRecord.Participant_Status__c == 'Excluded from Referring') {
                    this.showInclude = true;
                    this.showExclude = false;
                    this.showRefer = false;
                    this.showMRR = false;
                } else {
                    this.showInclude = false;
                    this.showExclude = true;
                }
                if (this.peRecordList[0].accessLevel == "Level 2") {
                    this.referbuttonDisable = true;
                } else if (this.peRecordList[0].accessLevel == "Level 3") {
                    this.isaccessLevelthree = true;
                    this.referbuttonDisable = true;
                    this.disabledSaveButton = true;
                }
                else {
                    this.referbuttonDisable = false;
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
                this.peRecordList = undefined;
                this.isLoading = false;
            });
    }

    checkLegalStatus(legalStatus) {
        if (legalStatus == 'Yes') {
            this.icon_Url_LegalStatus = community_icon + '/checkGreen.svg';
            this.legalStatus = true;
            this.emptyLegalStatus = false;
        }
        else if (legalStatus == 'No') {
            this.icon_Url_LegalStatus = community_icon + '/close.svg';
            this.isLegalStatus = false;
            this.emptyLegalStatus = false;
        }
        else {
            this.emptyLegalStatus = true;
        }
    }

    checkPatientAuthStatus(patientAuthStatus) {
        if (patientAuthStatus == 'Yes') {
            this.icon_Url_PatientAuthStatus = community_icon + '/checkGreen.svg';
            this.ispatientAuthStatus = true;
            this.emptyPatientAuthStatus = false;
        }
        else if (patientAuthStatus == 'No') {
            this.icon_Url_PatientAuthStatus = community_icon + '/close.svg';
            this.ispatientAuthStatus = false;
            this.emptyPatientAuthStatus = false;
        }
        else {
            this.emptyPatientAuthStatus = true;
        }
    }

    checkMedicalReviewStatus(medicalReviewStatus) {
        if (this.medicalreviewConfigured) {
            if (medicalReviewStatus == 'Pass') {
                this.icon_Url_MedicalReviewStatus = community_icon + '/checkGreen.svg';
                this.isMedicalReviewStatus = true;
                this.emptyMedicalReviewStatus = false;
                this.showRefer = true;
                this.showMRR = false;
            }
            else if (medicalReviewStatus == 'Fail') {
                this.icon_Url_MedicalReviewStatus = community_icon + '/close.svg';
                this.isMedicalReviewStatus = false;
                this.emptyMedicalReviewStatus = false;
                this.showRefer = true;
                this.showMRR = false;
            }
            else if (medicalReviewStatus == undefined) {
                this.emptyMedicalReviewStatus = true;
                this.showRefer = false;
                this.showMRR = true;
            }
        }
        else {
            this.showRefer = true;
            this.showMRR = false;
        }
    }

    checkPrescreeningStatus(prescreeningStatus) {

        if (prescreeningStatus == 'Pass') {
            this.icon_Url_PreEligibilityStatus = community_icon + '/checkGreen.svg';
            this.isPreEligibilityStatus = true;
            this.emptyPreEligibilityStatus = false;
        }
        else if (prescreeningStatus == 'Fail') {
            this.icon_Url_PreEligibilityStatus = community_icon + '/close.svg';
            this.isPreEligibilityStatus = false;
            this.emptyPreEligibilityStatus = false;
        }
        else {
            this.emptyPreEligibilityStatus = true;
        }
    }

    handlePatientTabChange(event) {
        this.peRecordList = [];
        this.peRecordList = event.detail.patientRecord;
        this.checkPatientAuthStatus(this.peRecordList[0].peRecord.Patient_Auth__c);
        this.checkLegalStatus(this.peRecordList[0].peRecord.Legal_Status__c);
        const selectedvalue = { peRecordList: this.peRecordList };
        const selectedEvent = new CustomEvent('patienttabrefresh', { detail: selectedvalue });
        this.dispatchEvent(selectedEvent);
    }

    handleDelegateChange(event) {
        this.peRecordList = event.detail.patientRecord;
    }
    handlePrimaryDelTab(){
            if(this.peRecordList[0].peRecord.Mailing_Country_Code__c=='US'){
                this.isCountryus=true;
            }
            else{
                this.isCountryus=false;
            }    
    }

    showSuccessToast(messageRec) {
        const evt = new ShowToastEvent({
            title: 'Success Message',
            message: messageRec,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    openExclude = false;
    openInclude = false;
    disableButton = false;

    openExcludeModal() {
        this.openExclude = true;
    }

    closeExcludeModal() {
        this.openExclude = false;
        this.disableButton = false;
    }

    openIncludeModal() {
        this.openInclude = true;
    }

    closeIncludeModal() {
        this.openInclude = false;
        this.disableButton = false;
    }

    //mobile
    showButtons = false;

    toggleButtons() {
        this.showButtons = !this.showButtons;
    }

    showSendOutreach = false;
    openOutreach(){
        this.showSendOutreach = true;
    }
    closeOutreachdModal(){
        this.showSendOutreach = false;
    }
}