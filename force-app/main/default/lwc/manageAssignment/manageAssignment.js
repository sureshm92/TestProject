import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PG_PST_L_Delegates_Remove_Mess_P1_New from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P1_New';
import PG_PST_L_Delegates_Remove_Mess_P3_New from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P3_New';
import PG_PST_L_Delegates_Remove_Himself_Header from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Himself_Header';
import PP_Delegate_Updated from '@salesforce/label/c.PP_Delegate_Updated';
import PP_Assignments from '@salesforce/label/c.PP_Assignments';
import PP_WithdraDel_info from '@salesforce/label/c.PP_WithdraDel_info';
import PP_Withdraw from '@salesforce/label/c.PP_Withdraw';
import PP_What_can_I_see_Or_Do from '@salesforce/label/c.PP_What_can_I_see_Or_Do';
import PP_Assigned_As_Primary_Delegate from '@salesforce/label/c.PP_Assigned_As_Primary_Delegate';
import PP_Assigned_As_Primary_Delegate_help from '@salesforce/label/c.PP_Assigned_As_Primary_Delegate_help';

//import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';
// import { loadScript } from 'lightning/platformResourceLoader';
// import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import getParAndStdAssociatedList from '@salesforce/apex/PatientDelegateEnrollmentService.getParAndStdAssociatedList';
import WithdrawAssignment from '@salesforce/apex/PatientDelegateEnrollmentService.WithdrawAssignment';
import largeTemplate from './manageAssignmentDesktop.html';
import mobileTemplate from './manageAssignmentMobile.html';
import formFactor from '@salesforce/client/formFactor';
import PG_PST_L_Delegates_Compl_Task_Behalf_New from '@salesforce/label/c.PG_PST_L_Delegates_Compl_Task_Behalf_New';
import PG_PST_L_Delegates_Receive_Emails_New from '@salesforce/label/c.PG_PST_L_Delegates_Receive_Emails_New';
import PG_PST_L_Delegates_See_Lab_Result_New from '@salesforce/label/c.PG_PST_L_Delegates_See_Lab_Result_New';
import PG_PST_L_Delegates_My_Measur_New from '@salesforce/label/c.PG_PST_L_Delegates_My_Measur_New';
import PG_PST_L_Delegates_See_Vitals_New from '@salesforce/label/c.PG_PST_L_Delegates_See_Vitals_New';
import PP_AS_CONDITIONAL_FEATURE from '@salesforce/label/c.PP_AS_CONDITIONAL_FEATURE';
import PP_Delegates_Permitted_Actions from '@salesforce/label/c.PP_Delegates_Permitted_Actions';

import {
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
export default class ManageAssignment extends NavigationMixin(LightningElement) {
    @api userMode;
    @api hasPatientDelegates;
    @api isDelegate;
    @api ParticipantStateValue;
    @api isRTL;
    @track parAndStdAssociatedList = [];
    @wire(MessageContext)
    messageContext;
    subscription = null;
    icon_url = pp_icons + '/Avatar_Delegate.svg';
    noDelIcon_url = pp_icons + '/Avatar-Delegate-Gray.svg';
    selectMenuTriagleDown_url = pp_icons + '/SelectMenuTriangleDown_blue.svg';
    iconChevronleRight_url = pp_icons + '/Chevron-Right-Blue.svg';
    spinner = false;
    loaded = false;
    showpopup = false;
    withdrawStudyPDEId;
    showWhatCanISeeCard = false;
    isDesktop;
    dataInitialized = false;

    label = {
        PP_ManageDelegates,
        PG_PST_L_Delegates_Remove_Mess_P1_New,
        PG_PST_L_Delegates_Remove_Mess_P3_New,
        PG_PST_L_Delegates_Remove_Himself_Header,
        PP_Delegate_Updated,
        PG_PST_L_Delegates_Compl_Task_Behalf_New,
        PG_PST_L_Delegates_Receive_Emails_New,
        PG_PST_L_Delegates_See_Lab_Result_New,
        PG_PST_L_Delegates_My_Measur_New,
        PG_PST_L_Delegates_See_Vitals_New,
        PP_AS_CONDITIONAL_FEATURE,
        PP_Delegates_Permitted_Actions,
        PP_Assignments,
        PP_WithdraDel_info,
        PP_Withdraw,
        PP_What_can_I_see_Or_Do,
        PP_Assigned_As_Primary_Delegate,
        PP_Assigned_As_Primary_Delegate_help
    };

    connectedCallback() {
        formFactor != 'Small' ? (this.isDesktop = true) : (this.isDesktop = false);
        this.initializeData();
        this.subscribeToMessageChannel();
    }

    render() {
        //return this.isDesktop ? manageAssignmentDesktop : manageAssignmentMobile;
        return formFactor === 'Small' ? mobileTemplate : largeTemplate;
    }

    initializeData() {
        this.spinner = true;
        //Get participant and associated Patient Delegate Enrollment records.
        getParAndStdAssociatedList()
            .then((result) => {
                this.setInitializedData(result);
                this.spinner = false;
                this.dataInitialized = true;
            })
            .catch((error) => {
                this.spinner = false;
            });
    }

    setInitializedData(result) {
        this.parAndStdAssociatedList = result;
        this.setDefaultValuesToInItData(this.parAndStdAssociatedList);
    }
    //this method will separate email chars in two parts to partially mask the email address.
    setDefaultValuesToInItData(parAndStdAssociatedList) {
        parAndStdAssociatedList.forEach((par) => {
            this.maskEmail(par);
            //Add Additional default flags in the list of PDEnrollments.
            //pde['isPrimaryDelegate'] = false;
            par.PDEEnrollments.forEach((pden) => {
                pden['isPrimaryDelegate'] = false;
                if (pden.Primary_Delegate__c) {
                    pden.isPrimaryDelegate = true;
                }
            });
        });
    }

    //mask Email for participants
    maskEmail(par) {
        let pdeEmailLength = par.Participant.Email__c.length;
        let maskedEmail = '';
        for (let i = 0; i < pdeEmailLength; i++) {
            if (i <= 2) {
                maskedEmail += par.Participant.Email__c.charAt(i);
            } else {
                maskedEmail += '*';
            }
        }
        par.Participant.Email__c = maskedEmail;
    }
    //Subscribe the message channel to read the message published.
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                messageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    //Handler for message received by Aura component
    handleMessage(message) {}
    //Subscribe the message channel
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    get addDelBtnMarin() {
        return this.isRTL
            ? 'mr-5 add-Delegate-Btn slds-float_left'
            : 'ml-5 add-Delegate-Btn slds-float_right';
    }
    // get addDelBtnMarinMobile() {
    //     return this.isRTL
    //         ? 'slds-m-top_small slds-p-left_large'
    //         : 'slds-m-top_small slds-p-right_large';
    // }
    get removeDelBtn() {
        return this.isRTL
            ? 'ml-24p remove-Delegate-Btn slds-float_left'
            : 'mr-24p remove-Delegate-Btn slds-float_right';
    }
    get removeDelBtnMobile() {
        return this.isRTL
            ? 'ml-24p remove-Delegate-Btn slds-float_left h-40'
            : 'mr-24p remove-Delegate-Btn slds-float_right h-40';
    }
    get studyCodeNameClass() {
        return this.isRTL ? 'mr-27p study-code-name' : 'ml-27p study-code-name h-40';
    }
    get studyCodeNameClassMobile() {
        return this.isRTL ? 'mr-27p study-code-name' : 'ml-27p study-code-name h-40';
    }
    M;
    get addAssignmentBtn() {
        return this.isRTL
            ? 'slds-align_absolute-center add-assignment-Btn'
            : 'slds-align_absolute-center add-assignment-Btn';
    }
    get addAssignmentBtnMobile() {
        return this.isRTL
            ? 'slds-align_absolute-center add-assignment-Btn h-40'
            : 'slds-align_absolute-center add-assignment-Btn h-40';
    }

    get delInfoActive() {
        return this.isRTL ? 'slds-p-right_large' : 'slds-p-left_large';
    }
    get delInfoActiveMob() {
        return this.isRTL ? 'slds-p-right_small' : 'slds-p-left_small';
    }
    get delAvararIcon() {
        return this.isRTL
            ? 'slds-p-right_small slds-p-top_xx-small'
            : 'slds-p-left_small slds-p-top_xx-small';
    }
    get delAvararIconMobile() {
        return this.isRTL
            ? 'slds-p-right_small slds-p-top_x-small'
            : 'slds-p-left_small slds-p-top_x-small';
    }
    get whatICanSeeIconClass() {
        return this.isRTL
            ? 'what-I-can-see-btn-icon slds-float_left '
            : 'what-I-can-see-btn-icon slds-float_right ';
    }
    get conChevronleRight() {
        return this.isRTL ? 'conChevronle-float-left' : 'conChevronle-float-right';
    }
    get conChevronleDownClass() {
        return this.isRTL
            ? 'con-chevronle-down conChevronle-float-left'
            : 'con-chevronle-down conChevronle-float-right';
    }
    //This method will open Remove Delegate Modal.
    openWithdrawDelegateModal(event) {
        this.withdrawStudyPDEId = event.currentTarget.dataset.pdeid;
        this.showpopup = true;
        //this.withdrawStudyPDEId = event.currentTarget.dataset.pdeid;
    }

    //This method will remove the delegate once Confirm button clicked on Remove Delegate Modal.
    handleWithdrawDelegate(event) {
        this.spinner = true;
        let pdEnrollmentId = event.detail.pdenrollmentid;
        WithdrawAssignment({
            pdeId: pdEnrollmentId
        })
            .then((result) => {
                this.showpopup = false;
                this.setInitializedData(result);
                this.spinner = false;
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }
    handleModalClose(event) {
        const showHideModal = event.detail;
        this.showpopup = showHideModal;
        this.withdrawStudyPDEId = '';
    }

    //This method will collapse and expand the what I can see as delegate card.
    toggleshowWhatCanISeeCardView() {
        this.showWhatCanISeeCard = this.showWhatCanISeeCard == true ? false : true;
    }
}
