import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Remove from '@salesforce/label/c.PP_Remove';
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

    label = {
        BTN_Add_New_Delegate,
        PP_ManageDelegates,
        PP_Remove
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
            let emailFirstThreeChars = '';
            let emailRemainingChars = '';
            for (let i = 0; i < pdeEmailLength; i++) {
                if (i <= 2) {
                    emailFirstThreeChars += pde.PatientDelegate.Email__c.charAt(i);
                } else {
                    emailRemainingChars += pde.PatientDelegate.Email__c.charAt(i);
                }
            }
            pde.PatientDelegate['emailFirstThreeChars'] = emailFirstThreeChars;
            pde.PatientDelegate['emailRemainingChars'] = emailRemainingChars;
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
    removeDelAssociationFromStudy(event) {
        let pdeId = event.target.dataset.id;
        //alert('TODO: remove this PDeId Record:  ' + pdeId);
        this.spinner = true;
        removeAssignment({ pDEId: pdeId })
            .then((returnValue) => {
                console.log('success second', returnValue);
                this.listPDE = returnValue;
                this.maskEmail();
                //this.initializeData();
                this.spinner = false;
            })
            .catch((error) => {
                console.log('error');
                this.spinner = false;
            });

        //TODO: logic TBD
    }
}
