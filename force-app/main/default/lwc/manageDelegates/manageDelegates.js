import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Remove from '@salesforce/label/c.PP_Remove';
import PG_PST_L_Delegates_Remove_Mess_P1 from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P1';
import PG_PST_L_Delegates_Remove_Mess_P3 from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P3';
import PG_PST_L_Delegates_Remove_Himself_Header from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Himself_Header';
import PP_Delegate_Updated from '@salesforce/label/c.PP_Delegate_Updated';
import PP_ActiveDelegates from '@salesforce/label/c.PP_ActiveDelegates';
import PP_FormerDelegates from '@salesforce/label/c.PP_FormerDelegates';
import PP_AddAssignment from '@salesforce/label/c.PP_AddAssignment';
import PP_DelegateWithdrawn from '@salesforce/label/c.PP_DelegateWithdrawn';
import PP_Delegate_Delegate_Warning from '@salesforce/label/c.PP_Delegate_Delegate_Warning';
import PP_Delegate_Delegate from '@salesforce/label/c.PP_Delegate_Delegate';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import PP_Delegate_Email_Consent from '@salesforce/label/c.PP_Delegate_Email_Consent';
import PIR_Discard from '@salesforce/label/c.PIR_Discard';
//import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import pirResources from '@salesforce/resourceUrl/pirResources';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import getPDE from '@salesforce/apex/PatientDelegateEnrollmentService.getPDE';
import removeAssignment from '@salesforce/apex/PatientDelegateEnrollmentService.removeAssignment';
import deleteDelegates from '@salesforce/apex/PatientDelegateEnrollmentService.deleteDelegates';
import manageDelegateDesktop from './manageDelegatesDesktop.html';
import manageDelegateMobile from './manageDelegatesMobile.html';
import DEVICE from '@salesforce/client/formFactor';

import {
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
export default class ManageDelegates extends NavigationMixin(LightningElement) {
    @api isDelegate;
    @api participantState;
    isDesktop;
    @api consentPreferenceData;
    @api userMode;
    @api isRTL;
    @track listPDE = [];
    @track formerListPDE = [];
    @wire(MessageContext)
    messageContext;
    subscription = null;
    icon_url = pp_icons + '/Avatar_Delegate.svg';
    noDelIcon_url = pp_icons + '/Avatar-Delegate-Gray.svg';
    selectMenuTriagleDown_url = pp_icons + '/SelectMenuTriangleDown_blue.svg';
    iconTriangleRight_url = pp_icons + '/iconTriangleRight_blue.svg';
    deleteIcon = pirResources + '/pirResources/icons/trash-delete.svg';
    deleteIconRed = pirResources + '/pirResources/icons/trash-delete-red.svg';
    spinner = false;
    loaded = false;
    showAddDelegatePage = false;
    showpopup = false;
    showDeletePopup = false;
    modalMesstext;
    showActiveDelegates = true;
    showFormerDelegates = true;
    hasNoActiveDelegate = true;
    hasNoFormerDelegate = true;
    addNewStudy = false;
    validateData = false; //TODO: write logic.
    //showDeleteRedIcon = false;

    label = {
        BTN_Add_New_Delegate,
        PP_ManageDelegates,
        PP_Remove,
        PG_PST_L_Delegates_Remove_Mess_P1,
        PG_PST_L_Delegates_Remove_Mess_P3,
        PG_PST_L_Delegates_Remove_Himself_Header,
        PP_Delegate_Updated,
        PP_ActiveDelegates,
        PP_FormerDelegates,
        PP_AddAssignment,
        PP_DelegateWithdrawn,
        PP_Delegate_Delegate_Warning,
        PP_Delegate_Delegate,
        BTN_Save,
        PP_Delegate_Email_Consent,
        PIR_Discard
    };

    connectedCallback() {
        //this.spinner = true;
        // Get Initial Load Data
        //this.spinner = false;
        DEVICE != 'Small' ? (this.isDesktop = true) : (this.isDesktop = false);

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

    render() {
        return this.isDesktop ? manageDelegateDesktop : manageDelegateMobile;
    }

    initializeData() {
        this.spinner = true;
        getPDE()
            .then((returnValue) => {
                console.log('success', returnValue);
                // this.listPDE = returnValue;
                this.listPDE = returnValue.activePDEWrapperList;
                this.formerListPDE = returnValue.formerPDEWrapperList;
                this.spinner = false;
                this.maskEmail(this.listPDE, true);
                this.maskEmail(this.formerListPDE, false);
                this.setActiveAndFormerDelegateFlags();
            })
            .catch((error) => {
                console.log('error');
                this.spinner = false;
            });
    }

    setActiveAndFormerDelegateFlags() {
        this.hasNoActiveDelegate = this.listPDE.length == 0 ? true : false;
        this.hasNoFormerDelegate = this.formerListPDE.length == 0 ? true : false;
    }
    //this method will separate email chars in two parts to partially mask the email address.
    maskEmail(pdeList, activeDelegates) {
        pdeList.forEach((pde) => {
            let pdeEmailLength = pde.PatientDelegate.Email__c.length;
            let maskedEmail = '';
            for (let i = 0; i < pdeEmailLength; i++) {
                if (i <= 2) {
                    maskedEmail += pde.PatientDelegate.Email__c.charAt(i);
                } else {
                    maskedEmail += '*';
                }
            }
            pde['addNewStudy'] = false;
            pde.PatientDelegate.Email__c = maskedEmail;

            //Also check if the Status of PDEnrollment is active or not.
            if (activeDelegates) {
                pde.PDEEnrollments.forEach((pden) => {
                    if (pden.Status__c === 'Active') {
                        pden['isActive'] = true;
                    } else {
                        pden['isActive'] = false;
                    }
                });
            } else {
                //Former Delegate
                pde['showDeleteRedIcon'] = false;
            }
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
    get saveButtonClass() {
        return this.validateData
            ? 'save-del-btn btn-save-opacity addDelegateMobile'
            : 'save-del-btn addDelegateMobile';
    }
    //Navigate to Add delegate screen
    navToAddDelegate() {
        //communityService.navigateToPage('new-team-member');
        this.showAddDelegatePage = true;
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
    openDeleteDelegateModal() {
        this.showDeletePopup = true;
    }

    //This method will remove the delegate once Confirm button clicked on Remove Delegate Modal.
    handleConfirmdelete(event) {
        this.spinner = true;
        let pdEnrollmentId = event.detail.pdenrollmentid;
        removeAssignment({
            pDEId: pdEnrollmentId
        })
            .then((result) => {
                this.showpopup = false;
                this.listPDE = result;
                this.listPDE = result.activePDEWrapperList;
                this.formerListPDE = result.formerPDEWrapperList;
                this.maskEmail(this.listPDE, true);
                this.maskEmail(this.formerListPDE, false);
                this.setActiveAndFormerDelegateFlags();
                this.spinner = false;
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
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
    handleDeleteModalClose(event) {
        const showHideModal = event.detail;
        this.showDeletePopup = showHideModal;
    }

    handleDeleteDelegate(event) {
        //TODO: Correct the logic.
        this.spinner = true;
        let patientdelegateid = event.detail.patientdelegateid;
        deleteDelegates({
            pdId: patientdelegateid
        })
            .then((result) => {
                this.listPDE = result;
                this.listPDE = result.activePDEWrapperList;
                this.formerListPDE = result.formerPDEWrapperList;
                this.maskEmail(this.listPDE, true);
                this.maskEmail(this.formerListPDE, false);
                this.setActiveAndFormerDelegateFlags();
                this.spinner = false;
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
                this.showDeletePopup = false;
            })
            .catch((error) => {
                console.log('error');
                this.spinner = false;
            });
    }
    //This method will toggle the Active delegate view
    toggleActiveDelegateView() {
        this.showActiveDelegates = this.showActiveDelegates == true ? false : true;
    }
    //This method will toggle the Former delegate view
    toggleFormerDelegateView() {
        this.showFormerDelegates = this.showFormerDelegates == true ? false : true;
    }
    addAssignment(event) {
        let delId = event.currentTarget.dataset.pdid;
        this.listPDE.forEach((pden) => {
            if (pden.PatientDelegate.Id === delId) {
                pden.addNewStudy = true;
            }
        });
    }
    discardAssignment(event) {
        let delId = event.currentTarget.dataset.pdid;
        this.listPDE.forEach((pden) => {
            if (pden.PatientDelegate.Id === delId) {
                pden.addNewStudy = false;
            }
        });
    }

    //Flipt the delete icon between gray and red.
    toggleDeleteIcon(event) {
        let recordId = event.currentTarget.dataset.id;
        this.formerListPDE.filter(function (del) {
            if (del.PatientDelegate.Id === recordId) {
                //del.showDeleteRedIcon = true;
                del.showDeleteRedIcon = del.showDeleteRedIcon ? false : true;
            }
        });
    }
}
