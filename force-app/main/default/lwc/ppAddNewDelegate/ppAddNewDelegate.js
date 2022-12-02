import { LightningElement, track, api, wire } from 'lwc';
import PG_NTM_L_Personal_Information from '@salesforce/label/c.PG_NTM_L_Personal_Information';
import PG_AS_F_Email_address from '@salesforce/label/c.PG_AS_F_Email_address';
import PG_AS_F_First_name from '@salesforce/label/c.PG_AS_F_First_name';
import PG_AS_F_Last_name from '@salesforce/label/c.PG_AS_F_Last_name';

// importing Custom Label
import TST_You_cannot_add_yourself_as_a_delegate from '@salesforce/label/c.TST_You_cannot_add_yourself_as_a_delegate';
import PG_NTM_L_Team_member from '@salesforce/label/c.PG_NTM_L_Team_member';
import PG_PST_L_Delegates_Delegate from '@salesforce/label/c.PG_PST_L_Delegates_Delegate';

import PG_NTM_L_Already_Exists from '@salesforce/label/c.PG_NTM_L_Already_Exists';

import PG_NTM_BTN_Back_to_My_Team from '@salesforce/label/c.PG_NTM_BTN_Back_to_My_Team';
import PG_PST_L_Delegates_Back from '@salesforce/label/c.PG_PST_L_Delegates_Back';

import TST_You_cannot_add_referring_provider_as_a_delegate from '@salesforce/label/c.TST_You_cannot_add_referring_provider_as_a_delegate';
import TST_You_cannot_add_primary_investigator_as_a_delegate from '@salesforce/label/c.TST_You_cannot_add_primary_investigator_as_a_delegate';
import PG_NTM_L_Permission_level_will_apply_to_all_studies from '@salesforce/label/c.PG_NTM_L_Permission_level_will_apply_to_all_studies';
import PP_DelegateAlreadyExists from '@salesforce/label/c.PP_DelegateAlreadyExists';
import PP_ActiveDelegateError from '@salesforce/label/c.PP_ActiveDelegateError';
import PP_Delegate_Added_Successfully from '@salesforce/label/c.PP_Delegate_Added_Successfully';
//import Profile_Information from '@salesforce/label/c.Profile_Information';

import getContactData from '@salesforce/apex/MyTeamRemote.getContactData';
import getMaxLength from '@salesforce/apex/MyTeamRemote.getMaxLength';
import isExistingDelegate from '@salesforce/apex/MyTeamRemote.isExistingDelegate';
import savePatientDelegate from '@salesforce/apex/MyTeamRemote.savePatientDelegate';
import getFilterData from '@salesforce/apex/MyTeamRemote.getFilterData';
import PP_Attestation_Confirmation_Message_For_Teams from '@salesforce/label/c.PP_Attestation_Confirmation_Message_For_Teams';
import PP_Email_Error from '@salesforce/label/c.PP_Email_Error';
import PP_Required_Field from '@salesforce/label/c.PP_Required_Field';
import PP_Delegate_Email_Consent from '@salesforce/label/c.PP_Delegate_Email_Consent';
import Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import Btn_Add_Delegate from '@salesforce/label/c.Add_Delegate';
import Back_to_Manage_Delegates from '@salesforce/label/c.Back_to_Manage_Delegates';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PG_PST_L_Delegates_Compl_Task_Behalf from '@salesforce/label/c.PG_PST_L_Delegates_Compl_Task_Behalf';
import PG_PST_L_Delegates_Receive_Emails from '@salesforce/label/c.PG_PST_L_Delegates_Receive_Emails';
import PG_PST_L_Delegates_See_Lab_Result from '@salesforce/label/c.PG_PST_L_Delegates_See_Lab_Result';
import PG_PST_L_Delegates_My_Measur from '@salesforce/label/c.PG_PST_L_Delegates_My_Measur';
import PP_AS_CONDITIONAL_FEATURE from '@salesforce/label/c.PP_AS_CONDITIONAL_FEATURE';
import PP_Delegates_Permitted_Actions from '@salesforce/label/c.PP_Delegates_Permitted_Actions';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import PP_Warning from '@salesforce/label/c.PP_Communication_Pref_Warning';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import {
    publish,
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
export default class PpAddNewDelegate extends LightningElement {
    @api isDesktop;
    @track delegate = {};
    @api selectedParent;
    isAttested = false;
    isEmailConsentChecked = false;
    isAtLeastOneStudySelected = false;
    @track allTrialLevel = {};
    isDelegateExisting = false;
    cmpinitialized = false;
    @track delegateOptions = [];
    currentUserContactId = '';
    parentFullName = '';
    userMode;
    isStaff = false;
    isCorrectEmail = false;
    isCorrectContactData = false;
    @track changedLevels = [];
    parentId = '';
    currentTab = 'by-study';
    @track changedLevelsAll = [];
    @track maxLengthData = {};
    @track studiesSelected = [];
    isDelegateActive = false;
    spinner = false;
    isLoading = false;
    @api delegateFilterData = [];
    @api totalNoOfStudies;
    @wire(MessageContext)
    messageContext;
    subscription = null;
    icon_url = pp_icons + '/Chevron-Right-Blue.svg';
    exclamation = LOFI_LOGIN_ICONS + '/status-exclamation.svg';
    //errorIconPosition = 'margin-left: 0px';
    existingDelegateWarning  = false;
    errorLabelText = 'The user associated with email address provided is already assigned as your delegate. You may add assignments to existing delegates in';
    label = {
        PG_NTM_L_Personal_Information,
        PG_NTM_L_Team_member,
        PG_PST_L_Delegates_Delegate,
        PG_AS_F_Email_address,
        PG_AS_F_First_name,
        PG_AS_F_Last_name,
        TST_You_cannot_add_yourself_as_a_delegate,
        TST_You_cannot_add_referring_provider_as_a_delegate,
        TST_You_cannot_add_primary_investigator_as_a_delegate,
        PG_NTM_L_Permission_level_will_apply_to_all_studies,
        PP_DelegateAlreadyExists,
        PP_ActiveDelegateError,
        PG_PST_L_Delegates_Back,
        PG_NTM_BTN_Back_to_My_Team,
        PG_NTM_L_Already_Exists,
        PP_Delegate_Added_Successfully,
        //Profile_Information,
        PP_Attestation_Confirmation_Message_For_Teams,
        PP_Email_Error,
        PP_Required_Field,
        PP_Delegate_Email_Consent,
        Add_New_Delegate,
        Btn_Add_Delegate,
        Back_to_Manage_Delegates,
        PG_PST_L_Delegates_Compl_Task_Behalf,
        PG_PST_L_Delegates_Receive_Emails,
        PG_PST_L_Delegates_See_Lab_Result,
        PG_PST_L_Delegates_My_Measur,
        PP_AS_CONDITIONAL_FEATURE,
        PP_Delegates_Permitted_Actions,
        PP_Warning,
        PP_ManageDelegates
    };
    backToDelegates(event) {
        const selectedEvent = new CustomEvent('backtodelegates', {
            detail: { usermode: this.userMode, selectedparent: this.selectedParent }
        });
        this.dispatchEvent(selectedEvent);
    }

    get firstNameDisabledCheck() {
        if (this.delegate) {
            if (this.delegate.delegateContact != undefined && this.delegate.delegateContact != '') {
                if (
                    this.delegate.delegateContact.Id != undefined &&
                    this.delegate.delegateContact.Id != ''
                ) {
                    return true;
                } else {
                    return false;
                }
            } else return false;
        } else return false;
    }
    get lastNameDisabledCheck() {
        if (this.delegate) {
            if (this.delegate.delegateContact != undefined && this.delegate.delegateContact != '') {
                if (
                    this.delegate.delegateContact.Id != undefined &&
                    this.delegate.delegateContact.Id != ''
                ) {
                    return true;
                } else {
                    return false;
                }
            } else return false;
        } else return false;
    }

    get validateData() {
        let savedisabled = false;
        savedisabled =
            (!this.isCorrectEmail && !this.isCorrectContactData) ||
            this.delegate.delegateContact.FirstName == null ||
            this.delegate.delegateContact.FirstName == '' ||
            this.delegate.delegateContact.FirstName.length == 0 ||
            this.delegate.delegateContact.LastName == null ||
            this.delegate.delegateContact.LastName == '' ||
            this.delegate.delegateContact.LastName.length == 0 ||
            this.delegate.delegateContact.Id == this.currentUserContactId ||
            !this.isAttested ||
            !this.isEmailConsentChecked ||
            !this.isAtLeastOneStudySelected;
        return savedisabled;
    }
    get saveButtonClass() {
        return this.validateData
            ? 'save-del-btn btn-save-opacity addDelegateMobile'
            : 'save-del-btn addDelegateMobile';
    }
    handleDateChange(event) {
        if (event.currentTarget.dataset.id == 'firstNameInput') {
            this.delegate.delegateContact.FirstName = event.target.value;
            this.doCheckContactData();
        }
        if (event.currentTarget.dataset.id == 'emailInput') {
            this.delegate.delegateContact.Email = event.target.value;
            this.doCheckEmail();
        }
        if (event.currentTarget.dataset.id == 'lastNameInput') {
            this.delegate.delegateContact.LastName = event.target.value;
            this.doCheckContactData();
        }
        if (event.currentTarget.dataset.id == 'consentcheck') {
            this.isAttested = event.target.checked;
        }
        if (event.currentTarget.dataset.id == 'emailconsentcheck') {
            this.isEmailConsentChecked = event.target.checked;
        }
    }
    connectedCallback() {
        if (!communityService.isDummy()) {
            this.isLoading = true;
            let userMode = communityService.getUserMode();
            this.userMode = userMode;
            console.log(' this.userMode:::' + this.userMode);
            if (
                userMode === 'Participant' &&
                communityService.getCurrentCommunityMode().isDelegate
            ) {
                communityService.navigateToHome();
            }
            let fields = ['FirstName', 'LastName'];
            let sObj = { sobjectType: 'Contact' };

            getMaxLength({
                so: JSON.stringify(sObj),
                fieldNames: fields
            })
                .then((result) => {
                    this.maxLengthData = result;
                })
                .catch((error) => {
                    this.isLoading = false;
                    communityService.showToast(
                        '',
                        'error',
                        'Failed To read the Data(Max Length)...',
                        100
                    );
                    this.spinner = false;
                });
            if (
                this.selectedParent != undefined &&
                this.selectedParent != null &&
                this.selectedParent != ''
            ) {
                this.parentId = this.selectedParent;
            }
            if (this.userMode) {
                getContactData({
                    userMode: this.userMode,
                    contactEmail: '',
                    parentId: this.parentId ? this.parentId : communityService.getDelegateId()
                })
                    .then((result) => {
                        let contactData = JSON.parse(result);
                        this.delegate = contactData.delegates[0];
                        if (this.delegate.delegateContact.Email == undefined) {
                            this.delegate.delegateContact.Email = '';
                        }
                        if (this.delegate.delegateContact.FirstName == undefined) {
                            this.delegate.delegateContact.FirstName = '';
                        }
                        this.delegateOptions = contactData.delegateOptions;
                        this.currentUserContactId = contactData.currentUserContactId;
                        this.parentFullName = contactData.parentFullName;
                        this.cmpinitialized = true;
                        this.isLoading = false;
                    })
                    .catch((error) => {
                        //alert('error');
                        this.isLoading = false;
                        communityService.showToast(
                            '',
                            'error',
                            'Failed To read the Data(Contact Data)...',
                            100
                        );
                        this.spinner = false;
                    });
                //get Available list of studies of participant
                // getFilterData({
                //     userMode: this.userMode
                // })
                //     .then((result) => {
                //         this.delegateFilterData = result;
                //         //Sent the List of studies via LMS to child component.
                //         // this.sendpiclistValues();
                //         this.totalNoOfStudies = result.studies.length;
                //         this.isLoading = false;
                //         this.spinner = false;
                //     })
                //     .catch((error) => {
                //         this.isLoading = false;
                //         communityService.showToast(
                //             '',
                //             'error',
                //             'Failed To read the Data(study Filter)...',
                //             100
                //         );
                //         this.spinner = false;
                //     });
            }
            this.subscribeToMessageChannel();
        } else {
            //alert('else block');
            console.log('else block');
        }
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    //Encapsulate logic for Lightning message service subscribe and unsubsubscribe
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
    //Handler for message received from child component.
    handleMessage(message) {
         //handle selected studies from the child component.
        if (message != undefined && message.selectedListOfStudies != undefined) {
            //this.delegateFilterData.studiesSelected = message.selectedListOfStudies;
            this.studiesSelected = message.selectedListOfStudies;
            if (message.selectedListOfStudies.length > 0) {
                this.isAtLeastOneStudySelected = true;
            } else if (message.selectedListOfStudies.length == 0) {
                this.isAtLeastOneStudySelected = false;
            }
        }
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    //Partially Mask the field
    partiallyMaskFields(value) {
        let maskedValue = '';
        for (let i = 0; i < value.length; i++) {
            if (i <= 1) {
                maskedValue += value.charAt(i);
            } else {
                maskedValue += '*';
            }
        }
        return maskedValue;
    }
    //Validate input field
    doValidateField(event) {
        let fieldId = event.currentTarget.dataset.id;
        let value = event.currentTarget.value;
        //alert('value: ' + value);
        if (fieldId === 'firstNameInput') {
            let firstNameInput = this.template.querySelector('[data-id="firstNameInput"]');
            if (!value) {
                firstNameInput.setCustomValidity(this.label.PP_Required_Field);
                firstNameInput.reportValidity();
            } else {
                firstNameInput.setCustomValidity('');
                firstNameInput.reportValidity();
            }
        }
        if (fieldId === 'lastNameInput') {
            let lastNameInput = this.template.querySelector('[data-id="lastNameInput"]');
            if (!value) {
                lastNameInput.setCustomValidity(this.label.PP_Required_Field);
                lastNameInput.reportValidity();
            } else {
                lastNameInput.setCustomValidity('');
                lastNameInput.reportValidity();
            }
        }
    }
    doSearchContact() {
        let email = this.template.querySelector('[data-id="emailInput"]');
        let delegate = this.delegate;
        if (
            delegate.delegateContact.Email != undefined &&
            delegate.delegateContact.Email != '' &&
            !communityService.isValidEmail(delegate.delegateContact.Email.trim())
        ) {
            this.isCorrectEmail = false;
            delegate.delegateContact.Id = null;
            this.delegate = delegate;
            email.setCustomValidity(this.label.PP_Email_Error);
            email.reportValidity();
            return;
        } else {
            email.setCustomValidity('');
            email.reportValidity();
            this.isCorrectEmail = true;
        }

        let oldFirstName = delegate.delegateContact.FirstName;
        let oldLastName = delegate.delegateContact.LastName;
        this.isLoading = true;
        getContactData({
            userMode: this.userMode,
            contactEmail: delegate.delegateContact.Email.toLowerCase().trim(),
            parentId: communityService.getUrlParameter('id')
                ? communityService.getUrlParameter('id')
                : communityService.getDelegateId()
        })
            .then((result) => {
                let contactData = JSON.parse(result);
                this.delegate = contactData.delegates[0];
                //Partially mask first Name
                let firstNameElement = this.template.querySelector('[data-id="firstNameInput"]');
                let lastNameElement = this.template.querySelector('[data-id="lastNameInput"]');
                this.delegate.delegateContact.FirstName = this.partiallyMaskFields(
                    this.delegate.delegateContact.FirstName
                );
                //Partially mask Last Name
                this.delegate.delegateContact.LastName = this.partiallyMaskFields(
                    this.delegate.delegateContact.LastName
                );
                firstNameElement.value = this.delegate.delegateContact.FirstName;
                lastNameElement.value = this.delegate.delegateContact.LastName;
                //Reset the custom blank error on FirstName and Last Name input if present.
                if (firstNameElement.value) {
                    firstNameElement.setCustomValidity('');
                    firstNameElement.reportValidity();
                }
                if (lastNameElement.value) {
                    lastNameElement.setCustomValidity('');
                    lastNameElement.reportValidity();
                }

                console.log('isActive--->' + this.delegate.isActive);
                this.isDelegateActive = this.delegate.isActive;
                if (
                    contactData.delegates[0].delegateContact.Id === contactData.currentUserContactId
                ) {
                    communityService.showToast(
                        '',
                        'error',
                        this.label.TST_You_cannot_add_yourself_as_a_delegate,
                        100
                    );
                } else if (
                    contactData.delegates[0].delegateContact.Id === undefined &&
                    delegate.delegateContact.Id === undefined
                ) {
                    this.template.querySelector('[data-id="firstNameInput"]').value = oldFirstName;
                    this.template.querySelector('[data-id="lastNameInput"]').value = oldLastName;
                }

                let allTrialLevel = {
                    delegateLevel: '',
                    trialName: this.label.PG_NTM_L_Permission_level_will_apply_to_all_studies
                };
                this.allTrialLevel = allTrialLevel;
                let studyDelegateLavelItems =
                    this.template.querySelector('[data-id="study-level"]');
                if (studyDelegateLavelItems) {
                    for (let i = 0; i < studyDelegateLavelItems.length; i++) {
                        studyDelegateLavelItems[i].refresh();
                    }
                }
                this.changedLevels = [];
                this.changedLevelsAll = [];
                this.checkeExistingDelegate();
                //this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;

                console.log('error' + error);
            });
    }

    checkeExistingDelegate(){
        //Check if it is existing delegate: Starts
        let delegate = this.delegate;
                isExistingDelegate({
                    delegate: JSON.stringify(delegate.delegateContact)
                })
                    .then((result) => {
                        this.isDelegateExisting = result;
                        // if (this.isDelegateExisting) {
                            // console.log('this.delegate.isActive' + this.delegate.isActive);
                            // if (!this.delegate.isActive) {
                            //     communityService.showToast(
                            //         '',
                            //         'error',
                            //         this.label.PP_DelegateAlreadyExists,
                            //         100
                            //     );
                            // } else {
                            //     communityService.showToast(
                            //         '',
                            //         'error',
                            //         this.label.PP_ActiveDelegateError,
                            //         100
                            //     );
                            // }
                            //component.find('mainSpinner').hide();
                            
                        // }
                        // this.existingDelegateWarning = true;
                        this.isLoading = false;
                        return;

                })
                    .catch((error) => {
                        communityService.showToast(
                            '',
                            'error',
                            'Failed To read the Data(existing Delegate)...',
                            100
                        );
                        this.spinner = false;
                        this.isLoading = false;
                    });
                //Check  if it is existing delegate: Ends
    }
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach((inputField) => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    doSaveChanges() {
        let delegate = this.delegate;
        // let allTrialLevel = this.allTrialLevel;
        //let currentTab = this.currentTab;

        if (this.isInputValid()) {
            this.isLoading = true;
            delegate.delegateContact.FirstName = delegate.delegateContact.FirstName.trim();
            delegate.delegateContact.LastName = delegate.delegateContact.LastName.trim();

            if (this.userMode === 'Participant') {
                console.log(
                    'JSON.stringify(delegate.delegateContact)' +
                        JSON.stringify(delegate.delegateContact)
                );
                console.log('isAttested' + this.isAttested);
                console.log('isEmailConsentChecked' + this.isEmailConsentChecked);

                //Save Delegate
                savePatientDelegate({
                                delegate: JSON.stringify(delegate.delegateContact),
                                delegateFilterData: JSON.stringify(this.studiesSelected)
                            })
                                .then((result) => {
                                    communityService.showToast(
                                        '',
                                        'success',
                                        this.label.PP_Delegate_Added_Successfully,
                                        100
                                    );
                                    this.isAttested = false;
                                    this.isEmailConsentChecked = false;
                                    this.template.querySelector(
                                        '[data-id="firstNameInput"]'
                                    ).value = '';
                                    this.template.querySelector('[data-id="lastNameInput"]').value =
                                        '';

                                    this.template.querySelector('[data-id="emailInput"]').value =
                                        '';
                                    this.sendFilterUpdates();
                                    this.goBackToManageDelegate();
                                    this.isLoading = false;
                                })
                                .catch((error) => {
                                    this.isLoading = false;
                                    //alert('error:::' + error);
                                });

                // isExistingDelegate({
                //     delegate: JSON.stringify(delegate.delegateContact)
                // })
                //     .then((result) => {
                //         this.isDelegateExisting = result;
                //         console.log('inside save-->' + this.delegate.isActive);
                //         console.log('isDelegateExisting' + this.isDelegateExisting);

                //         if (this.isDelegateExisting) {
                //             console.log('this.delegate.isActive' + this.delegate.isActive);
                //             if (!this.delegate.isActive) {
                //                 communityService.showToast(
                //                     '',
                //                     'error',
                //                     this.label.PP_DelegateAlreadyExists,
                //                     100
                //                 );
                //             } else {
                //                 communityService.showToast(
                //                     '',
                //                     'error',
                //                     this.label.PP_ActiveDelegateError,
                //                     100
                //                 );
                //             }
                //             //component.find('mainSpinner').hide();
                //             this.isLoading = false;
                //             return;
                //         } else {
                //             //consol.log('delegateFilterData: ',JSON.stringify(this.studiesSelected));
                //             savePatientDelegate({
                //                 delegate: JSON.stringify(delegate.delegateContact),
                //                 delegateFilterData: JSON.stringify(this.studiesSelected)
                //             })
                //                 .then((result) => {
                //                     communityService.showToast(
                //                         '',
                //                         'success',
                //                         this.label.PP_Delegate_Added_Successfully,
                //                         100
                //                     );
                //                     this.isAttested = false;
                //                     this.isEmailConsentChecked = false;
                //                     this.template.querySelector(
                //                         '[data-id="firstNameInput"]'
                //                     ).value = '';
                //                     this.template.querySelector('[data-id="lastNameInput"]').value =
                //                         '';

                //                     this.template.querySelector('[data-id="emailInput"]').value =
                //                         '';
                //                     this.sendFilterUpdates();
                //                     this.goBackToManageDelegate();
                //                     this.isLoading = false;
                //                 })
                //                 .catch((error) => {
                //                     this.isLoading = false;
                //                     //alert('error:::' + error);
                //                 });
                //         }
                //     })
                //     .catch((error) => {
                //         communityService.showToast(
                //             '',
                //             'error',
                //             'Failed To read the Data(existing Delegate)...',
                //             100
                //         );
                //         this.spinner = false;
                //         this.isLoading = false;
                //     });
            } else {
                this.isLoading = false;
                /*component
            .find('saveDelegateLevelChanges')
            .execute(delegate, component, delegate.delegateContact.Id === undefined);*/
            }
        }
    }

    doCheckEmail() {
        let delegate = this.delegate;
        console.log('doCheckEmail delegate:::' + JSON.stringify(delegate));
        if (delegate.delegateContact.Email != undefined && delegate.delegateContact.Email != '') {
            this.isCorrectEmail = communityService.isValidEmail(delegate.delegateContact.Email);
        }
    }

    doCheckContactData() {
        let delegate = this.delegate;
        this.isCorrectContactData =
            delegate.delegateContact.FirstName.trim() !== '' &&
            delegate.delegateContact.LastName.trim() !== '';
    }
    //Send Reset All to True to child component PP_MultiPickistLWC to reset the multipicklist value.
    //This LMS will be subscribe in connectedCallback in PP_MultiPickistLWC LWC comp.
    sendFilterUpdates() {
        const returnPayload = {
            ResetAll: true
        };
        publish(this.messageContext, messageChannel, returnPayload);
    }
    //Send Study Picklist value to Child component.
    //This LMS will be subscribe in connectedCallback in PP_MultiPickistLWC LWC comp.
    // sendpiclistValues() {
    //     const returnPayload = {
    //         piclistValues: this.delegateFilterData.studies
    //     };
    //     publish(this.messageContext, messageChannel, returnPayload);
    // }

    //Go back to manage delegate page
    //This LMS will be subscribe in connectedCallback in ManageDelegate LWC comp.
    goBackToManageDelegate() {
        const returnPayload = {
            showAddDelegatePage: false
        };
        publish(this.messageContext, messageChannel, returnPayload);
    }
}