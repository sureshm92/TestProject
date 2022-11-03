import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Remove from '@salesforce/label/c.PP_Remove';
import PG_PST_L_Delegates_Remove_Mess_P1 from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P1';
import PG_PST_L_Delegates_Remove_Mess_P3 from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P3';
import PG_PST_L_Delegates_Remove_Himself_Header from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Himself_Header';
import PP_Delegate_Updated from '@salesforce/label/c.PP_Delegate_Updated';
//import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import getPDE from '@salesforce/apex/PatientDelegateEnrollmentService.getPDE';
import removeAssignment from '@salesforce/apex/PatientDelegateEnrollmentService.removeAssignment';
import {
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
export default class ManageDelegates extends NavigationMixin(LightningElement) {
    @api isDelegate;
    @api participantState;
    @api isDesktop;
    @api consentPreferenceData;
    @api userMode;
    @api isRTL;
    @track listPDE;
    @wire(MessageContext)
    messageContext;
    subscription = null;
    icon_url = pp_icons + '/Avatar_Delegate.svg';
    spinner = false;
    loaded = false;
    showAddDelegatePage = false;
    showpopup = false;
    modalMesstext;

    label = {
        BTN_Add_New_Delegate,
        PP_ManageDelegates,
        PP_Remove,
        PG_PST_L_Delegates_Remove_Mess_P1,
        PG_PST_L_Delegates_Remove_Mess_P3,
        PG_PST_L_Delegates_Remove_Himself_Header,
        PP_Delegate_Updated
    };

    connectedCallback() {
        //this.spinner = true;
        // Get Initial Load Data
        //this.spinner = false;

        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                if (communityService.isMobileSDK()) {
                    this.isDesktop = false;
                }
            });
            // getisRTL()
            //     .then((data) => {
            //         this.isRTL = data;
            //     })
            //     .catch(function (error) {
            //         console.error('Error RTL: ' + JSON.stringify(error));
            //     });
        }
        this.initializeData();
        this.subscribeToMessageChannel();
    }
    initializeData() {
        this.spinner = true;
        getPDE()
            .then((returnValue) => {
                console.log('success', returnValue);
                this.listPDE = returnValue;
                this.spinner = false;
                this.maskEmail();
            })
            .catch((error) => {
                console.log('error');
                this.spinner = false;
            });
    }

    //this method will separate email chars in two parts to partially mask the email address.
    maskEmail() {
        this.listPDE.forEach((pde) => {
            let pdeEmailLength = pde.PatientDelegate.Email__c.length;
            let maskedEmail = '';
            for (let i = 0; i < pdeEmailLength; i++) {
                if (i <= 2) {
                    maskedEmail += pde.PatientDelegate.Email__c.charAt(i);
                } else {
                    maskedEmail += '*';
                }
            }
            pde.PatientDelegate.Email__c = maskedEmail;
        });
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
    handleMessage(message) {
        //If we backToManageDelegate = false when we click on back to Manage delegate button.
        if (message.showAddDelegatePage == false) {
            //this.spinner = true;
            this.initializeData();
            this.showAddDelegatePage = false;

            //this.spinner = false;
        }
    }
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
    get addDelBtnMarinMobile() {
        return this.isRTL
            ? 'mr-5 add-Delegate-Btn slds-float_left h-40'
            : 'ml-5 add-Delegate-Btn slds-float_right h-40';
    }
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

    //Navigate to Add delegate screen
    navToAddDelegate() {
        //communityService.navigateToPage('new-team-member');
        this.showAddDelegatePage = true;
    }
    addAssignment() {
        alert('TODO: Write Add Assignment Logic');
        //TODO: logic TBD
    }
    //This method will open Remove Delegate Modal.
    openRemoveDelegateModal(event) {
        this.showpopup = true;
        let pdfn = event.target.dataset.pdfn;
        let pdln = event.target.dataset.pdln;
        this.modalMesstext =
            this.label.PG_PST_L_Delegates_Remove_Mess_P1 +
            ' ' +
            pdfn +
            ' ' +
            pdln +
            ' ' +
            this.label.PG_PST_L_Delegates_Remove_Mess_P3;
    }
    //This method will remove the delegate once Confirm button clicked on Remove Delegate Modal.
    handleConfirmdelete(event) {
        this.spinner = true;
        let pdEnrollmentId = event.detail.pdenrollmentid;
        removeAssignment({
            pDEId: pdEnrollmentId
        })
            .then((result) => {
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
                this.listPDE = result;
                this.maskEmail();
                this.showpopup = false;
                this.spinner = false;
            })
            .catch((error) => {
                console.log('error');
                this.spinner = false;
            });
    }
    handleModalClose(event) {
        const showHideModal = event.detail;
        this.showpopup = showHideModal;
    }
}
