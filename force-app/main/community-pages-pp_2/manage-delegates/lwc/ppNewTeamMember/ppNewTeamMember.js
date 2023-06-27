import { LightningElement, track, api } from 'lwc';
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
import TST_You_have_successfully_created_permissions_for from '@salesforce/label/c.TST_You_have_successfully_created_permissions_for';
import Profile_Information from '@salesforce/label/c.Profile_Information';

import getContactData from '@salesforce/apex/MyTeamRemote.getContactData';
import getMaxLength from '@salesforce/apex/MyTeamRemote.getMaxLength';
import isExistingDelegate from '@salesforce/apex/MyTeamRemote.isExistingDelegate';
import savePatientDelegate from '@salesforce/apex/MyTeamRemote.savePatientDelegate';
import PP_Attestation_Confirmation_Message_For_Teams from '@salesforce/label/c.PP_Attestation_Confirmation_Message_For_Teams';
import PP_Email_Error from '@salesforce/label/c.PP_Email_Error';
import PP_Required_Field from '@salesforce/label/c.PP_Required_Field';

export default class PpNewTeamMember extends LightningElement {
    @track delegate = {};
    @api selectedParent;
    isAttested = false;
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
    isDelegateActive = false;
    spinner = false;
    isLoading = false;

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
        TST_You_have_successfully_created_permissions_for,
        Profile_Information,
        PP_Attestation_Confirmation_Message_For_Teams,
        PP_Email_Error,
        PP_Required_Field
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
    /*get delexistingmsg() {
        if (this.delegate) {
            if (
                this.delegate.delegateContact != undefined &&
                this.delegate.delegateContact != '' &&
                this.delegate.delegateContact != null
            ) {
                if (
                    this.delegate.delegateContact.Id != undefined &&
                    this.delegate.delegateContact.Id != null &&
                    this.delegate.delegateContact.Id != ''
                ) {
                    if (!this.isStaff) {
                        return (
                            this.label.PG_PST_L_Delegates_Delegate +
                            ' ' +
                            this.delegate.delegateContact.FirstName +
                            ' ' +
                            this.delegate.delegateContact.LastName +
                            ' ' +
                            this.label.PG_NTM_L_Already_Exists
                        );
                    }
                }
            }
        }
    }
    */

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
            !this.isAttested;
        return savedisabled;
    }
    get saveButtonClass() {
        return this.validateData ? 'profile-info-btn btn-save-opacity' : 'profile-info-btn';
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
                    communityService.showToast('', 'error', 'Failed To read the Data...', 100);
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
                        communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                        this.spinner = false;
                    });
            }
        } else {
            //alert('else block');
            console.log('else block');
        }
    }
    //Partially Mask the field
    partiallyMaskFields(value) {
        let maskedValue = '';
        let resetValidationError = false;
        for (let i = 0; i < value.length; i++) {
            if (i == 0) {
                maskedValue += value.charAt(0);
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
                //let userMode = this.userMode;
                //let parentId = this.parentId;
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
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;

                console.log('error' + error);
            });
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
                isExistingDelegate({
                    delegate: JSON.stringify(delegate.delegateContact)
                })
                    .then((result) => {
                        this.isDelegateExisting = result;
                        console.log('inside save-->' + this.delegate.isActive);
                        console.log('isDelegateExisting' + this.isDelegateExisting);

                        if (this.isDelegateExisting) {
                            console.log('this.delegate.isActive' + this.delegate.isActive);
                            if (!this.delegate.isActive) {
                                communityService.showToast(
                                    '',
                                    'error',
                                    this.label.PP_DelegateAlreadyExists,
                                    100
                                );
                            } else {
                                communityService.showToast(
                                    '',
                                    'error',
                                    this.label.PP_ActiveDelegateError,
                                    100
                                );
                            }
                            //component.find('mainSpinner').hide();
                            this.isLoading = false;
                            return;
                        } else {
                            savePatientDelegate({
                                delegate: JSON.stringify(delegate.delegateContact)
                            })
                                .then((result) => {
                                    communityService.showToast(
                                        '',
                                        'success',
                                        this.label
                                            .TST_You_have_successfully_created_permissions_for +
                                            ' ' +
                                            delegate.delegateContact.FirstName +
                                            ' ' +
                                            delegate.delegateContact.LastName,
                                        100
                                    );
                                    this.isAttested = false;
                                    this.template.querySelector(
                                        '[data-id="firstNameInput"]'
                                    ).value = '';
                                    this.template.querySelector('[data-id="lastNameInput"]').value =
                                        '';

                                    this.template.querySelector('[data-id="emailInput"]').value =
                                        '';
                                    this.isLoading = false;
                                })
                                .catch((error) => {
                                    this.isLoading = false;
                                    //alert('error:::' + error);
                                });
                        }
                    })
                    .catch((error) => {
                        communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                        this.spinner = false;
                        this.isLoading = false;
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
}
