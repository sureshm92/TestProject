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
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import getContactData from '@salesforce/apex/MyTeamRemote.getContactData';
import getDelegateContactData from '@salesforce/apex/MyTeamRemote.getDelegateContactData';
import getMaxLength from '@salesforce/apex/MyTeamRemote.getMaxLength';
import isExistingDelegate from '@salesforce/apex/MyTeamRemote.isExistingDelegate';
import savePatientDelegate from '@salesforce/apex/MyTeamRemote.savePatientDelegate';
import getFilterData from '@salesforce/apex/MyTeamRemote.getFilterData';
import Attestation_Confirmation_Message_For_Teams from '@salesforce/label/c.Attestation_Confirmation_Message_For_Teams';
import PP_Email_Error from '@salesforce/label/c.PP_Email_Error';
import PP_Required_Field from '@salesforce/label/c.PP_Required_Field';
import PP_Delegate_Email_Consent from '@salesforce/label/c.PP_Delegate_Email_Consent';
import Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import Btn_Add_Delegate from '@salesforce/label/c.Add_Delegate';
import Back_to_Manage_Delegates from '@salesforce/label/c.Back_to_Manage_Delegates';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PG_PST_L_Delegates_Compl_Task_Behalf_New from '@salesforce/label/c.PG_PST_L_Delegates_Compl_Task_Behalf_New';
import PG_PST_L_Delegates_Receive_Emails_New from '@salesforce/label/c.PG_PST_L_Delegates_Receive_Emails_New';
import PG_PST_L_Delegates_See_Lab_Result_New from '@salesforce/label/c.PG_PST_L_Delegates_See_Lab_Result_New';
import PG_PST_L_Delegates_My_Measur_New from '@salesforce/label/c.PG_PST_L_Delegates_My_Measur_New';
import PG_PST_L_Delegates_See_Vitals_New from '@salesforce/label/c.PG_PST_L_Delegates_See_Vitals_New';
import PP_AS_CONDITIONAL_FEATURE from '@salesforce/label/c.PP_AS_CONDITIONAL_FEATURE';
import PP_Delegates_Permitted_Actions from '@salesforce/label/c.PP_Delegates_Permitted_Actions';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import PP_Warning from '@salesforce/label/c.PP_Communication_Pref_Warning';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Confirm_Selection from '@salesforce/label/c.PP_Confirm_Selection';
import PP_ExistingDelError from '@salesforce/label/c.PP_ExistingDelError';
import PP_ExistingDelError_1 from '@salesforce/label/c.PP_ExistingDelError_1';
import PP_Select_User from '@salesforce/label/c.PP_Select_User';
import PP_There_Are from '@salesforce/label/c.PP_There_Are';
import PP_Users_Associated from '@salesforce/label/c.PP_Users_Associated';

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
    @track allDelegate = {};
    @api selectedParent;
    @api isRTL;
    isAttested = false;
    isEmailConsentChecked = false;
    isAtLeastOneStudySelected = false;
    //@track allTrialLevel = {};
    showExistingDelegateError = false;
    cmpinitialized = false;
    @track delegateOptions = [];
    currentUserContactId = '';
    parentFullName = '';
    userMode;
    isStaff = false;
    isCorrectEmail = false;
    isCorrectContactData = false;
    //@track changedLevels = [];
    parentId = '';
    currentTab = 'by-study';
    //@track changedLevelsAll = [];
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
    exclamation_orange = rr_community_icons + '/' + 'status-exclamation.svg';
    //errorIconPosition = 'margin-left: 0px';
    existingDelegateWarning = false;
    showExistingContactWarning = false;
    participantAddingHimselfError = false;
    selectedContact;
    diableFNLNWhenDupContacts = false;
    checkboxDisableflag = false;
    oldDelegate = {};
    oldFirstName;
    oldLastName;
    isContactSelected = false;
    isDeletedOrWithdrawnDelegate = false;
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
        Attestation_Confirmation_Message_For_Teams,
        PP_Email_Error,
        PP_Required_Field,
        PP_Delegate_Email_Consent,
        Add_New_Delegate,
        Btn_Add_Delegate,
        Back_to_Manage_Delegates,
        PG_PST_L_Delegates_Compl_Task_Behalf_New,
        PG_PST_L_Delegates_Receive_Emails_New,
        PG_PST_L_Delegates_See_Lab_Result_New,
        PG_PST_L_Delegates_My_Measur_New,
        PG_PST_L_Delegates_See_Vitals_New,
        PP_AS_CONDITIONAL_FEATURE,
        PP_Delegates_Permitted_Actions,
        PP_Warning,
        PP_ManageDelegates,
        PP_Confirm_Selection,
        PP_ExistingDelError,
        PP_ExistingDelError_1,
        PP_Select_User,
        PP_There_Are,
        PP_Users_Associated
    };
    backToDelegates() {
        const selectedEvent = new CustomEvent('backtodelegates', {
            detail: { usermode: this.userMode, selectedparent: this.selectedParent }
        });
        this.dispatchEvent(selectedEvent);
    }

    get firstNameDisabledCheck() {
        if (this.diableFNLNWhenDupContacts) {
            return true;
        }
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
        if (this.diableFNLNWhenDupContacts) {
            return true;
        }
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
            !this.isCorrectEmail ||
            this.delegate.delegateContact.FirstName == null ||
            this.delegate.delegateContact.FirstName == '' ||
            this.delegate.delegateContact.FirstName.length == 0 ||
            this.delegate.delegateContact.LastName == null ||
            this.delegate.delegateContact.LastName == '' ||
            this.delegate.delegateContact.LastName.length == 0 ||
            this.delegate.delegateContact.Id == this.currentUserContactId ||
            !this.isAttested ||
            !this.isEmailConsentChecked ||
            !this.isAtLeastOneStudySelected ||
            !this.isContactSelected;
        return savedisabled;
    }
    get saveButtonClass() {
        return this.validateData
            ? 'save-del-btn btn-save-opacity addDelegateMobile'
            : 'save-del-btn addDelegateMobile';
    }
    get whatDelCanSeeSection() {
        return this.isRTL
            ? 'slds-p-right_medium slds-p-top_medium slds-p-bottom_small'
            : 'slds-p-left_medium slds-p-top_medium slds-p-bottom_small';
    }
    get whatDeleCanSeeText() {
        return this.isRTL ? 'slds-p-right_medium' : 'slds-p-left_medium';
    }
    get checkBoxDisabled() {
        let checkBoxDisabled = false;
        if (
            this.showExistingDelegateError ||
            this.participantAddingHimselfError ||
            this.checkboxDisableflag
        ) {
            checkBoxDisabled = true;
        }
        return checkBoxDisabled;
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
    partiallyMaskFields() {
        this.allDelegate.forEach((del) => {
            let firstName = del.delegateContact.FirstName;
            let maskedFirstName = '';
            for (let i = 0; i < firstName.length; i++) {
                if (i <= 1) {
                    maskedFirstName += firstName.charAt(i);
                } else {
                    maskedFirstName += '*';
                }
            }
            del.delegateContact.FirstName = maskedFirstName;

            let lastName = del.delegateContact.LastName;
            let maskedLastName = '';
            for (let i = 0; i < lastName.length; i++) {
                if (i <= 1) {
                    maskedLastName += lastName.charAt(i);
                } else {
                    maskedLastName += '*';
                }
            }
            del.delegateContact.LastName = maskedLastName;
            del['fullNameMasked'] = maskedFirstName + ' ' + maskedLastName;
        });
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
        let emailElement = this.template.querySelector('[data-id="emailInput"]');
        this.delegate.delegateContact.Email = this.delegate.delegateContact.Email.trim();
        let delegate = this.delegate;
        let email = delegate.delegateContact.Email.trim();
        // let oldEmail =
        //     this.oldDelegate.delegateContact != undefined
        //         ? this.oldDelegate.delegateContact.Email
        //         : '';
        // if (oldEmail != '' && oldEmail == this.delegate.delegateContact.Email) {
        //     return;
        // }
        //If email is null/undefined
        if (email == undefined || email == '') {
            this.isCorrectEmail = true;
            return;
        } else if (
            email != undefined &&
            email != '' &&
            !communityService.isValidEmail(email.trim())
        ) {
            this.isCorrectEmail = false;
            delegate.delegateContact.Id = null;
            this.delegate = delegate;
            emailElement.setCustomValidity(this.label.PP_Email_Error);
            emailElement.reportValidity();
            return;
        } else {
            emailElement.setCustomValidity('');
            emailElement.reportValidity();
            this.isCorrectEmail = true;
        }

        this.showExistingDelegateError = false;
        this.showExistingContactWarning = false;
        this.participantAddingHimselfError = false;
        this.diableFNLNWhenDupContacts = false;
        this.checkboxDisableflag = false;
        this.isContactSelected = false;
        this.oldDelegate = delegate;
        this.isLoading = true;
        getDelegateContactData({
            userMode: this.userMode,
            contactEmail: email.toLowerCase().trim(),
            parentId: communityService.getUrlParameter('id')
                ? communityService.getUrlParameter('id')
                : communityService.getDelegateId()
        })
            .then((result) => {
                emailElement.setCustomValidity('');
                emailElement.reportValidity();
                let contactData = JSON.parse(result);
                let contDataLength = contactData.delegates.length;
                this.allDelegate = contactData.delegates;
                this.currentUserContactId = contactData.currentUserContactId;
                //this.delegate = {};
                //partially Mask First Name and Last Name.
                this.partiallyMaskFields();
                //Reset the pre filled input values if Present.
                this.resetInputValues(false);
                //When only one existing contact is present.
                if (contDataLength == 1) {
                    this.delegate = this.allDelegate[0];
                    this.setSelectedOrFirstContactInputs();
                    this.isContactSelected = true;
                    //When existing contact is available.
                    if (this.allDelegate[0].delegateContact.Id != undefined) {
                        this.diableFNLNWhenDupContacts = true;
                    }
                } else {
                    //If More than one existing contacts found for given email.
                    this.showExistingContactWarning = true;
                    this.sendMessageToDisableMultipicklist(true);
                    this.allDelegate.forEach((delegate) => {
                        //check Delegate status.
                        let status = delegate.status;
                        let isActiveDelegate = delegate.isActive;
                        let isFormerDelegate =
                            !isActiveDelegate &&
                            (status === 'Disconnected' || status === 'On Hold');
                        //If Delegate is Active/former(Not Withdrawn).
                        if (isActiveDelegate || isFormerDelegate) {
                            this.showExistingContactWarning = false;
                            this.showExistingDelegateError = true;
                        }
                    });
                    this.diableFNLNWhenDupContacts = true;
                    this.checkboxDisableflag = true;
                    this.isLoading = false;
                    return;
                }
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                this.isLoading = false;
            });
    }

    setSelectedOrFirstContactInputs() {
        let firstNameElement = this.template.querySelector('[data-id="firstNameInput"]');
        let lastNameElement = this.template.querySelector('[data-id="lastNameInput"]');
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

        //If participant Tries to add himself as delegate, throw error message.
        if (
            this.delegate.delegateContact != undefined &&
            this.delegate.delegateContact.Id != undefined &&
            this.delegate.delegateContact.Id === this.currentUserContactId
        ) {
            this.participantAddingHimselfError = true;
            communityService.showToast(
                '',
                'error',
                this.label.TST_You_cannot_add_yourself_as_a_delegate,
                100
            );
        } else if (
            this.delegate.delegateContact.Id === undefined &&
            this.oldDelegate.delegateContact.Id === undefined
        ) {
            this.template.querySelector('[data-id="firstNameInput"]').value =
                this.oldDelegate.delegateContact.FirstName;
            this.template.querySelector('[data-id="lastNameInput"]').value =
                this.oldDelegate.delegateContact.LastName;
            this.showExistingContactWarning = false;
        }
        //check Delegate status.
        let status = this.delegate.status;
        let isActiveDelegate = this.delegate.isActive;
        let isFormerDelegate =
            !isActiveDelegate && (status === 'Disconnected' || status === 'On Hold');
        let isDeletedOrWithdrawnDelegate =
            !isActiveDelegate && (status === 'Deleted' || status === 'Withdrawn');
        var disableMultipicklist = false;
        //If Delegate is Active/former(Not Withdrawn).
        if (isActiveDelegate || isFormerDelegate) {
            this.showExistingDelegateError = true;
            disableMultipicklist = true;
        } else if (isDeletedOrWithdrawnDelegate) {
            //if Delegate is withdrwan or Deleted
            this.isDeletedOrWithdrawnDelegate = true;
        }
        this.sendMessageToDisableMultipicklist(disableMultipicklist);
        this.isLoading = false;
        //this.checkeExistingDelegate();
    }

    checkeExistingDelegate() {
        //this.showExistingDelegateError = false;
        //Check if it is existing delegate: Starts
        let delegate = this.delegate;
        isExistingDelegate({
            delegate: JSON.stringify(delegate.delegateContact)
        })
            .then((result) => {
                this.showExistingDelegateError = result;
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

                let selectedStudies = [];
                this.studiesSelected.forEach((std) => {
                    let assigned = false;
                    //if Deleted or Withdrawn delegate added again.
                    if (this.isDeletedOrWithdrawnDelegate) {
                        assigned = true;
                    }
                    selectedStudies.push({
                        label: std.label,
                        value: std.value,
                        assigned: assigned,
                        active: false,
                        pdEnrollmentId: null
                    });
                });

                //Save Delegate
                savePatientDelegate({
                    delegate: JSON.stringify(delegate.delegateContact),
                    delegateFilterData: JSON.stringify(selectedStudies)
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
                        this.resetInputValues(true);
                        this.goBackToManageDelegate();
                        this.isLoading = false;
                    })
                    .catch((error) => {
                        communityService.showToast('', 'error', 'Failed To save the Data...', 100);
                        this.isLoading = false;
                        //alert('error:::' + error);
                    });
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
    //Go back to manage delegate page
    //This LMS will be subscribe in connectedCallback in ManageDelegate LWC comp.
    goBackToManageDelegate() {
        const returnPayload = {
            showAddDelegatePage: false
        };
        publish(this.messageContext, messageChannel, returnPayload);
    }
    //Send Reset All to True to child component PP_MultiPickistLWC to reset the multipicklist value.
    //This LMS will be subscribe in connectedCallback in PP_MultiPickistLWC LWC comp.
    sendMessageToDisableMultipicklist(isDisabledFlag) {
        const returnPayload = {
            isDisabled: isDisabledFlag
        };
        publish(this.messageContext, messageChannel, returnPayload);
    }

    //This method will confirm the selected contact among multiple contacts.
    confirmSelection(event) {
        this.isLoading = true;
        this.checkboxDisableflag = false;
        //Filter out the selected contact from list of all contacts.
        this.allDelegate.forEach((del) => {
            if (del.delegateContact.Id == this.selectedContact) {
                this.delegate = del;
            }
        });
        this.setSelectedOrFirstContactInputs();
        this.showExistingContactWarning = false;
    }
    //This method will set the selected contact among multiple contacts.
    setSelectedContact(event) {
        this.selectedContact = event.target.value;
        console.log('selectedContact: ' + this.selectedContact);
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
        //Unslect the previously selected checkbox and keep the latest selection.
        for (var i = 0; i < checkboxes.length; ++i) {
            if (checkboxes[i].value != this.selectedContact) {
                checkboxes[i].checked = false;
            } else {
                if (checkboxes[i].checked) {
                    this.isContactSelected = true;
                } else {
                    this.isContactSelected = false;
                }
            }
        }
    }
    //Return the total number of existing contacts found.
    get existingContactsCount() {
        return this.allDelegate.length;
    }
    get disableConfirmSelectionBtn() {
        return this.isContactSelected ? false : true;
    }

    get isAddNewDelegate() {
        return true;
    }

    //Reset the pre filled input values if Present.
    resetInputValues(clearEmail) {
        this.template.querySelector('[data-id="firstNameInput"]').value = '';
        this.template.querySelector('[data-id="lastNameInput"]').value = '';
        this.template.querySelector('[data-id="consentcheck"]').checked = false;
        this.template.querySelector('[data-id="emailconsentcheck"]').checked = false;
        this.template.querySelector('[data-id="consentcheck"]').checked = false;
        this.isAttested = false;
        this.isEmailConsentChecked = false;
        if (clearEmail) {
            this.template.querySelector('[data-id="emailInput"]').value = '';
        }
        this.sendFilterUpdates();
    }
}
