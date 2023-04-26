import { LightningElement, api, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import JANUARY from '@salesforce/label/c.January';
import FEBRUARY from '@salesforce/label/c.February';
import MARCH from '@salesforce/label/c.March';
import APRIL from '@salesforce/label/c.April';
import MAY from '@salesforce/label/c.May';
import JUNE from '@salesforce/label/c.June';
import JULY from '@salesforce/label/c.July';
import AUGUST from '@salesforce/label/c.August';
import SEPTEMBER from '@salesforce/label/c.September';
import OCTOBER from '@salesforce/label/c.October';
import NOVEMBER from '@salesforce/label/c.November';
import DECEMBER from '@salesforce/label/c.December';
import DOB_ERROR from '@salesforce/label/c.PP_DOB_ERROR';
import BACK from '@salesforce/label/c.Back';
import PROFILE_INFO from '@salesforce/label/c.PG_Login_H_Profile_Information';
import GENERAL_INFO from '@salesforce/label/c.PP_General_Info';
import PREFIX from '@salesforce/label/c.PP_Prefix';
import FIRST_NAME from '@salesforce/label/c.PP_FirstName';
import MIDDLE_INITIAL from '@salesforce/label/c.PG_AS_F_Middle_name';
import LAST_NAME from '@salesforce/label/c.PP_LastName';
import SUFFIX from '@salesforce/label/c.PG_AS_F_Suffix';
import PREFERRED_NAME from '@salesforce/label/c.PP_Preferred_Name';
import GENDER from '@salesforce/label/c.cont_study_gender';
import DOB from '@salesforce/label/c.PG_AS_F_Date_of_Birth';
import MOBILE_PHONE from '@salesforce/label/c.Mob_Phone_Field';
import USE_AS_DAYTIME_PHONE from '@salesforce/label/c.PP_USE_AS_DAYTIME_PHONE';
import DAYTIME_PHONE from '@salesforce/label/c.PP_Daytime_Phone';
import PHONE_TYPE from '@salesforce/label/c.Phone_Type';
import SAVE from '@salesforce/label/c.BTN_Save';
import CONTACT_INFO from '@salesforce/label/c.PG_AS_H_Contact_Information';
import EMAIL_PREF from '@salesforce/label/c.PP_EMAIL_COMMUNICATION_PREFERENCE';
import COMM_PREF from '@salesforce/label/c.Communication_Preferences';
import WARNING from '@salesforce/label/c.PP_Warning';
import EMAIL_WARNING_MESSAGE from '@salesforce/label/c.PP_UPDATE_EMAIL_WARNING';
import EMAIL_ADDRESS from '@salesforce/label/c.CPD_Email_address_label';
import HELP from '@salesforce/label/c.PG_HLP_H_Help';
import PAGE from '@salesforce/label/c.PP_Page';
import EMAIL_PATTERN from '@salesforce/label/c.RH_Email_Validation_Pattern';
import EMAIL_INVALID_CHARACTERS from '@salesforce/label/c.RH_Email_Invalid_Characters';
import EMAIL_FORMAT_ERROR from '@salesforce/label/c.PP_Email_Error';
import REQUIRED_FIELD from '@salesforce/label/c.PP_AS_REQUIRED_FIELD';
import INVALID_PHONE_FORMAT from '@salesforce/label/c.PP_AS_INVALID_PHONE_FORMAT';
import DATA_UPDATE from '@salesforce/label/c.PP_AS_DATA_UPDATE';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitDataSettingsEdit';
import changeEmail from '@salesforce/apex/AccountSettingsController.changeEmail';
import updatePerson from '@salesforce/apex/AccountSettingsController.updatePerson';
export default class PpAccountSettingsEditProfile extends LightningElement {
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @track initData;
    @track personWrapper;
    @track contact;
    @track oldContactEmail = '';
    @track delegateContact;
    userEmail = '';
    minorUserName = '';
    hasProfilePic = false;
    isInitialized = false;
    @api isDelegate = false;
    contactChanged = false;
    optInEmail = false;
    optInSMS = false;
    isAdult = false;
    newPrefix;
    disableMobileToggle = false;
    disableEmailToggle = false;
    @track isUseAsDaytimePhoneChecked = false;
    isMobilePhoneInvalid = false;
    isDOBInvalid = false;
    institute;
    userId;
    spinner;
    todayDate;
    commPrefMessage = '';
    emailWarningMessage = '';
    emailWarningIcon = LOFI_LOGIN_ICONS + '/status-exclamation.svg';
    @track hasFieldError = {
        isFNHasError: false,
        isLNHasError: false,
        isDOBHasError: false,
        isEmailHasError: false,
        isMPHasError: false,
        isDPHasError: false,
        isFieldChanged: false
    };
    labels = {
        ERROR_MESSAGE,
        DOB_ERROR,
        PROFILE_INFO,
        GENERAL_INFO,
        PREFIX,
        FIRST_NAME,
        LAST_NAME,
        MIDDLE_INITIAL,
        SUFFIX,
        PREFERRED_NAME,
        GENDER,
        DOB,
        MOBILE_PHONE,
        USE_AS_DAYTIME_PHONE,
        DAYTIME_PHONE,
        PHONE_TYPE,
        CONTACT_INFO,
        EMAIL_PREF,
        COMM_PREF,
        WARNING,
        BACK,
        EMAIL_WARNING_MESSAGE,
        EMAIL_ADDRESS,
        EMAIL_FORMAT_ERROR,
        REQUIRED_FIELD,
        INVALID_PHONE_FORMAT,
        HELP,
        PAGE,
        EMAIL_PATTERN,
        EMAIL_INVALID_CHARACTERS,
        SAVE,
        DATA_UPDATE
    };
    requiredFieldError = this.labels.REQUIRED_FIELD;
    emailFieldError = this.labels.EMAIL_FORMAT_ERROR;
    mobilePhoneFieldError = this.labels.INVALID_PHONE_FORMAT;
    daytimePhoneFieldError = this.labels.INVALID_PHONE_FORMAT;
    dobFieldError = this.labels.DOB_ERROR;
    @track dateOfBirth = {
        year: '',
        month: '',
        day: ''
    };

    @track monthsList = [
        { label: JANUARY, value: '01' },
        { label: FEBRUARY, value: '02' },
        { label: MARCH, value: '03' },
        { label: APRIL, value: '04' },
        { label: MAY, value: '05' },
        { label: JUNE, value: '06' },
        { label: JULY, value: '07' },
        { label: AUGUST, value: '08' },
        { label: SEPTEMBER, value: '09' },
        { label: OCTOBER, value: '10' },
        { label: NOVEMBER, value: '11' },
        { label: DECEMBER, value: '12' }
    ];

    daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    @track daysList = [];

    get yearsList() {
        let yearsOptions = [];
        let currentYear = new Date().getFullYear();
        let earliestYear = currentYear - 100;
        while (currentYear >= earliestYear) {
            let formattedYearNumber = earliestYear.toString();
            let yearOption = {
                label: formattedYearNumber,
                value: formattedYearNumber
            };
            earliestYear++;
            yearsOptions = [...yearsOptions, yearOption];
        }
        return yearsOptions;
    }

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner.show();
                        this.initializeData();
                    })
                    .catch((error) => {
                        console.log(error.body.message);
                    });
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    renderedCallback() {}
    initializeData() {
        getInitData({ userMode: this.userMode })
            .then((result) => {
                let initialData = JSON.parse(result);

                this.initData = initialData;
                this.personWrapper = initialData.contactSectionData.personWrapper;
                this.contactSectionData = initialData.contactSectionData;
                this.isUseAsDaytimePhoneChecked =
                    initialData.contactSectionData.personWrapper.useAsDaytimePhone;

                this.contact = initialData.myContact;
                this.oldContactEmail = initialData.myContact.Email;
                this.delegateContact = initialData.delegateContact;
                this.hasProfilePic = initialData.hasProfilePic;

                if (this.userMode === 'Participant') {
                    this.isAdult = initialData.participant.Adult__c;
                }
                /**Delegate */
                if (communityService.getCurrentCommunityMode().currentDelegateId) {
                    this.isDelegate = true;
                    this.userId = communityService.getCurrentCommunityMode().currentDelegateId;
                    if (this.userMode === 'Participant') {
                        if (
                            initialData.participant.Adult__c &&
                            initialData.delegateUserName != null
                        ) {
                            this.userEmail = initialData.delegateUserName.Username;
                        }
                        if (this.personWrapper.showBirthDate && this.personWrapper.dateBirth) {
                            this.parseDOB(this.personWrapper.dateBirth);
                        }
                    }
                } else {
                    this.isDelegate = false;
                    this.userId = initialData.myContact.Id;
                    if (
                        !this.isDelegate &&
                        !this.personWrapper.showBirthDate &&
                        !this.personWrapper.dateBirth
                    ) {
                        this.parseDelegateDOB(this.personWrapper.birthYear);
                    } else {
                        this.parseDOB(this.personWrapper.dateBirth);
                    }
                    if (this.userMode === 'Participant' && this.isAdult) {
                        this.userEmail = initialData.userName;
                    }
                }

                this.minorUserName = initialData.myContact.Email;

                /**Initial Toggle Validations */
                if (this.personWrapper && this.personWrapper.mobilePhone === '') {
                    this.disableMobileToggle = true;
                }
                if (this.contact && this.contact.Email === '') {
                    this.disableEmailToggle = true;
                }
                this.initializeLabels();
                this.isInitialized = true;
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    /**Add Styles to Dynamic Labels */
    initializeLabels() {
        this.commPrefMessage = this.labels.EMAIL_PREF.replace(
            '##COMM_PREF_LINK',
            `<a href="./account-settings?communication-preferences" style="font-weight:600;">${this.labels.COMM_PREF}</a>`
        );
        let warningText = this.labels.WARNING.replace(
            this.labels.WARNING,
            `<span style="color: #e20000; font-weight: bold">` +
                this.labels.WARNING +
                `&nbsp;</span>`
        );
        this.emailWarningMessage =
            warningText +
            this.labels.EMAIL_WARNING_MESSAGE.replace(
                '##HELPLINK',
                `<a href="./help" style="font-weight:600;">${this.labels.HELP}</a>`
            );

        let currentDate = new Date();
        let dateFormat = { year: 'numeric', month: 'long', day: '2-digit' };
        let formattedDate = currentDate.toLocaleDateString(LOCALE, dateFormat).toString();
        this.dobFieldError = this.labels.DOB_ERROR.replace('##TODAY', formattedDate);
    }

    /**CSS Getters START */

    get iconChevron() {
        return 'icon-chevron-left';
    }

    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    get shortContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_3-of-8 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-medium-size_1-of-7 slds-p-vertical_x-small';
    }

    get webSelectClass() {
        return this.isMobile ? 'as-width-mobile' : 'as-width';
    }

    get dobClass() {
        return this.isMobile ? 'dob-width-mobile' : 'as-width';
    }

    get longContainerClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-form-element slds-col slds-size_5-of-8 slds-p-vertical_x-small'
                : 'slds-form-element slds-col slds-size_5-of-8 slds-p-vertical_x-small slds-p-left_none'
            : this.isRTL
            ? 'slds-form-element slds-col slds-size_2-of-7 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_2-of-7 slds-p-vertical_x-small';
    }

    get xLongContainerClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-form-element slds-col slds-size_5-of-8 slds-p-vertical_x-small'
                : 'slds-form-element slds-col slds-size_5-of-8 slds-p-vertical_x-small slds-p-left_none'
            : 'slds-form-element slds-col slds-size_3-of-4 slds-medium-size_3-of-7 slds-p-vertical_x-small';
    }

    get genderContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_4-of-4 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_1-of-7 slds-p-vertical_x-small';
    }

    get genderComboboxClass() {
        return this.isMobile ? 'as-input-width' : '';
    }

    get dobContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_4-of-4 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_3-of-7 slds-p-vertical_x-small';
    }

    get dobFieldClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-col slds-size_1-of-3 slds-p-right_none slds-p-left_x-small'
                : 'slds-col slds-size_1-of-3 slds-p-left_none slds-p-right_x-small'
            : this.isRTL
            ? 'slds-col slds-size_1-of-3 slds-p-right_none slds-p-left_x-small'
            : 'slds-col slds-size_1-of-3 slds-p-left_none slds-p-right_x-small';
    }

    get dobInputClass() {
        return this.isDOBInvalid ? 'dropdown-error' : '';
    }

    get emailWarningContainerClass() {
        return this.isMobile
            ? 'slds-grid slds-wrap email-warning-container full-width'
            : 'slds-grid slds-wrap email-warning-container';
    }

    get emailWarningIconClass() {
        return this.isMobile
            ? 'slds-col slds-size_2-of-12 slds-align_absolute-center'
            : 'slds-col slds-size_1-of-12 slds-align_absolute-center';
    }

    get emailWarningMessageClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-col slds-size_10-of-12 email-warning-rtl slds-p-around_x-small email-warning-text-mobile'
                : 'slds-col slds-size_10-of-12 email-warning slds-p-around_x-small email-warning-text-mobile'
            : this.isRTL
            ? 'slds-col slds-size_11-of-12 email-warning-rtl slds-p-around_x-small'
            : 'slds-col slds-size_11-of-12 email-warning slds-p-around_x-small';
    }

    get emailContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_4-of-4 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_3-of-7 slds-p-vertical_x-small';
    }

    get mobileContainerClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-grid slds-wrap slds-gutters input-text-size slds-grid_vertical-align-center slds-p-right_small'
                : 'slds-grid slds-wrap slds-gutters input-text-size slds-grid_vertical-align-center slds-p-left_small'
            : this.isRTL
            ? 'slds-grid slds-wrap slds-gutters input-text-size slds-grid_vertical-align-center slds-p-right_small'
            : 'slds-grid slds-wrap slds-gutters input-text-size slds-grid_vertical-align-center slds-p-left_small';
    }

    get mobilePhoneContainerClass() {
        return this.isMobile ? 'slds-col slds-size_5-of-8' : 'slds-col slds-size_3-of-7';
    }

    get mobileInputClass() {
        return this.isMobile ? 'slds-input default-input mobile-input' : 'slds-input default-input';
    }

    get useAsDaytimeContainerClass() {
        return this.isMobile
            ? 'slds-col slds-size_5-of-8 slds-p-top_small custom-checkbox'
            : 'slds-col slds-size_2-of-7 custom-checkbox';
    }

    get daytimePhoneContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_5-of-8 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_3-of-7 slds-p-vertical_x-small';
    }

    get phoneTypeContainerClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-form-element slds-col slds-size_2-of-7 slds-p-vertical_x-small slds-p-right_none'
                : 'slds-form-element slds-col slds-size_3-of-8 slds-p-vertical_x-small slds-p-left_none'
            : this.isRTL
            ? 'slds-form-element slds-col slds-size_1-of-7 slds-p-vertical_x-small slds-p-left_none'
            : 'slds-form-element slds-col slds-size_1-of-7 slds-p-vertical_x-small slds-p-right_none';
    }

    get phoneTypeClass() {
        return this.isMobile ? 'phone-type-width-mobile' : 'long-width';
    }

    get phoneTypeWidthClass() {
        return this.isMobile ? 'as-long-input-width' : 'as-long-input-width';
    }

    get saveButtonContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_7-of-7 slds-p-vertical_x-small'
            : 'slds-form-element slds-col slds-size_1-of-7 slds-p-vertical_x-small';
    }

    get saveButtonClass() {
        return this.isMobile
            ? this.isSaveDisabled
                ? 'slds-button slds-button_brand save-button save-button-disabled full-width'
                : 'slds-button slds-button_brand save-button full-width'
            : this.isSaveDisabled
            ? 'slds-button slds-button_brand save-button save-button-disabled'
            : 'slds-button slds-button_brand save-button';
    }

    /**CSS Getters END */

    /**Conditional Variable Getters START */

    get isAdultUser() {
        return this.isAdult && this.userEmail;
    }

    get dobDisabled() {
        return this.isDelegate || (!this.isDelegate && !this.personWrapper.showBirthDate)
            ? true
            : false;
    }

    get isMobilePhoneDisabled() {
        return this.personWrapper.mailingCC !== 'US' ? true : false;
    }

    get isSaveDisabled() {
        if (
            !this.hasFieldError.isFNHasError &&
            !this.hasFieldError.isLNHasError &&
            !this.hasFieldError.isDOBHasError &&
            !this.hasFieldError.isEmailHasError &&
            !this.hasFieldError.isMPHasError &&
            !this.hasFieldError.isDPHasError &&
            this.hasFieldError.isFieldChanged
        ) {
            return false;
        } else {
            return true;
        }
    }

    /**Conditional Variable Getters END */

    handlePrefixChange(event) {
        this.personWrapper.prefix = event.detail;
        this.hasFieldError.isFieldChanged = true;
    }

    handleFirstNameChange(event) {
        let inputFistName = event.target.value;
        if (this.personWrapper.firstName != inputFistName) {
            this.personWrapper.firstName = inputFistName;
            this.hasFieldError.isFieldChanged = true;
            let firstNameField = this.template.querySelector(`[data-id="first-name-input"]`);
            if (!inputFistName) {
                firstNameField.setCustomValidity(this.requiredFieldError);
                firstNameField.reportValidity();
                this.showErrorInput('first-name-input');
                this.hasFieldError.isFNHasError = true;
            } else {
                firstNameField.setCustomValidity('');
                firstNameField.reportValidity();
                this.removeErrorInput('first-name-input');
                this.hasFieldError.isFNHasError = false;
            }
        }
    }

    handleMiddleNameChange(event) {
        let middleName = event.target.value;
        if (this.personWrapper.middleName != middleName) {
            this.personWrapper.middleName = middleName;
            this.hasFieldError.isFieldChanged = true;
        }
    }

    handleLastNameChange(event) {
        let inputLastName = event.target.value;
        if (this.personWrapper.lastName != inputLastName) {
            this.personWrapper.lastName = inputLastName;
            this.hasFieldError.isFieldChanged = true;
            let lastNameField = this.template.querySelector(`[data-id="last-name-input"]`);
            if (!inputLastName) {
                lastNameField.setCustomValidity(this.requiredFieldError);
                lastNameField.reportValidity();
                this.showErrorInput('last-name-input');
                this.hasFieldError.isLNHasError = true;
            } else {
                lastNameField.setCustomValidity('');
                lastNameField.reportValidity();
                this.removeErrorInput('last-name-input');
                this.hasFieldError.isLNHasError = false;
            }
        }
    }

    handleSuffixChange(event) {
        let suffix = event.target.value;
        if (this.personWrapper.suffix != suffix) {
            this.personWrapper.suffix = suffix;
            this.hasFieldError.isFieldChanged = true;
        }
    }

    handlePreferredNameChange(event) {
        let preferredName = event.target.value;
        if (this.personWrapper.nickname != preferredName) {
            this.personWrapper.nickname = preferredName;
            this.hasFieldError.isFieldChanged = true;
        }
    }

    handleGenderChange(event) {
        this.personWrapper.gender = event.detail;
        this.hasFieldError.isFieldChanged = true;
    }

    handleMonthChange(event) {
        if (this.dateOfBirth.month != event.detail) {
            this.dateOfBirth.month = event.detail;
            this.setAllowedDays(this.dateOfBirth.month);
            if (this.dateOfBirth.month && this.dateOfBirth.day && this.dateOfBirth.year) {
                let isDOBFuture = this.isFutureDOB(
                    this.dateOfBirth.month,
                    this.dateOfBirth.day,
                    this.dateOfBirth.year
                );
                this.handleDOBErrorMessage(isDOBFuture);
            }
        }
    }

    handleDayChange(event) {
        if (this.dateOfBirth.day != event.detail) {
            this.dateOfBirth.day = event.detail;
            if (this.dateOfBirth.month && this.dateOfBirth.day && this.dateOfBirth.year) {
                let isDOBFuture = this.isFutureDOB(
                    this.dateOfBirth.month,
                    this.dateOfBirth.day,
                    this.dateOfBirth.year
                );
                this.handleDOBErrorMessage(isDOBFuture);
            }
        }
    }

    handleYearChange(event) {
        if (this.dateOfBirth.year != event.detail) {
            this.dateOfBirth.year = event.detail;
            this.setAllowedDays(this.dateOfBirth.month);
            if (this.dateOfBirth.month && this.dateOfBirth.day && this.dateOfBirth.year) {
                let isDOBFuture = this.isFutureDOB(
                    this.dateOfBirth.month,
                    this.dateOfBirth.day,
                    this.dateOfBirth.year
                );
                this.handleDOBErrorMessage(isDOBFuture);
            }
        }
    }

    handleDOBErrorMessage(isDOBInValid) {
        let dobErrorElement = this.template.querySelector(`[data-id="dob-error-message"]`);
        this.personWrapper.dateBirth =
            this.dateOfBirth.year + '-' + this.dateOfBirth.month + '-' + this.dateOfBirth.day;
        if (!isDOBInValid) {
            this.isDOBInvalid = false;
            this.hasFieldError.isFieldChanged = true;
            this.hasFieldError.isDOBHasError = false;
            !dobErrorElement.classList.contains('slds-hide')
                ? dobErrorElement.classList.add('slds-hide')
                : 'Not Today!';
        } else {
            this.isDOBInvalid = true;
            this.hasFieldError.isFieldChanged = true;
            this.hasFieldError.isDOBHasError = true;
            dobErrorElement.classList.contains('slds-hide')
                ? dobErrorElement.classList.remove('slds-hide')
                : 'Not Today!';
        }
    }

    handleEmailChange(event) {
        let emailInput = event.target.value;
        if (this.contact.Email != emailInput) {
            this.contact.Email = emailInput;
            this.hasFieldError.isFieldChanged = true;

            if (emailInput) {
                let emailValidity = this.validateEmailFormat(emailInput);
                let emailField = this.template.querySelector(`[data-id="email-input"]`);
                if (emailValidity) {
                    this.removeErrorInput('email-input');
                    emailField.setCustomValidity('');
                    this.hasFieldError.isEmailHasError = false;
                } else {
                    this.showErrorInput('email-input');
                    emailField.setCustomValidity(this.emailFieldError);
                    this.hasFieldError.isEmailHasError = true;
                }
                emailField.reportValidity();
            } else {
                let emailField = this.template.querySelector(`[data-id="email-input"]`);
                this.showErrorInput('email-input');
                this.hasFieldError.isEmailHasError = true;
                emailField.setCustomValidity(this.emailFieldError);
                emailField.reportValidity();
            }
        }
    }

    handleMobilePhoneChange(event) {
        let mobilePhone = event.target.value;
        if (this.personWrapper.mobilePhone != mobilePhone) {
            this.personWrapper.mobilePhone = mobilePhone;
            this.hasFieldError.isFieldChanged = true;
            /**Mobile Not Empty Check */
            let mobilePhoneField = this.template.querySelector(`[data-id="mobile-phone-input"]`);
            if (mobilePhone) {
                let mobilePhoneValidity = this.validatePhoneFormat(mobilePhone);
                /**Mobile Pattern Validity Check */
                if (mobilePhoneValidity) {
                    if (this.personWrapper.useAsDaytimePhone) {
                        this.personWrapper.homePhone = this.personWrapper.mobilePhone;
                    }
                    this.removeErrorInput('mobile-phone-input');
                    this.isMobilePhoneInvalid = false;
                    this.hasFieldError.isMPHasError = false;
                    mobilePhoneField.setCustomValidity('');
                } else {
                    this.showErrorInput('mobile-phone-input');
                    mobilePhoneField.setCustomValidity(this.mobilePhoneFieldError);
                    this.isMobilePhoneInvalid = true;
                    this.hasFieldError.isMPHasError = true;
                }
                mobilePhoneField.reportValidity();
            } else if (
                (!mobilePhone && this.isMobilePhoneRequired) ||
                this.isUseAsDaytimePhoneChecked
            ) {
                this.showErrorInput('mobile-phone-input');
                mobilePhoneField.setCustomValidity(this.mobilePhoneFieldError);
                mobilePhoneField.reportValidity();
                this.isMobilePhoneInvalid = true;
                this.hasFieldError.isMPHasError = true;
            }
        }
    }

    handleUseAsDaytimePhone(event) {
        this.isUseAsDaytimePhoneChecked = !this.isUseAsDaytimePhoneChecked;
        this.personWrapper.useAsDaytimePhone = this.isUseAsDaytimePhoneChecked;
        this.hasFieldError.isFieldChanged = true;
        if (this.personWrapper.useAsDaytimePhone && this.personWrapper.mobilePhone) {
            this.personWrapper.homePhone = this.personWrapper.mobilePhone;
            this.personWrapper.phoneType = 'Mobile';
            let daytimePhoneField = this.template.querySelector(`[data-id="daytime-phone-input"]`);
            this.removeErrorInput('daytime-phone-input');
            daytimePhoneField.setCustomValidity('');
            daytimePhoneField.reportValidity();
            this.hasFieldError.isDPHasError = false;
        } else if (this.personWrapper.useAsDaytimePhone && !this.personWrapper.mobilePhone) {
            this.personWrapper.homePhone = this.personWrapper.mobilePhone;
            this.personWrapper.phoneType = 'Mobile';
            let mobilePhoneField = this.template.querySelector(`[data-id="mobile-phone-input"]`);
            this.showErrorInput('mobile-phone-input');
            mobilePhoneField.setCustomValidity(this.mobilePhoneFieldError);
            mobilePhoneField.reportValidity();
            this.isMobilePhoneInvalid = true;
            this.hasFieldError.isMPHasError = true;
        }
    }

    handleDaytimePhoneChange(event) {
        let daytimePhone = event.target.value;
        if (this.personWrapper.homePhone != daytimePhone) {
            this.personWrapper.homePhone = daytimePhone;
            this.hasFieldError.isFieldChanged = true;
            let daytimePhoneField = this.template.querySelector(`[data-id="daytime-phone-input"]`);
            if (daytimePhone) {
                let daytimePhoneValidity = this.validatePhoneFormat(daytimePhone);
                if (daytimePhoneValidity) {
                    this.removeErrorInput('daytime-phone-input');
                    daytimePhoneField.setCustomValidity('');
                    this.hasFieldError.isDPHasError = false;
                } else {
                    this.showErrorInput('daytime-phone-input');
                    daytimePhoneField.setCustomValidity(this.daytimePhoneFieldError);
                    this.hasFieldError.isDPHasError = true;
                }
                daytimePhoneField.reportValidity();
            } else {
                this.showErrorInput('daytime-phone-input');
                daytimePhoneField.setCustomValidity(this.daytimePhoneFieldError);
                daytimePhoneField.reportValidity();
                this.hasFieldError.isDPHasError = true;
            }
        }
    }

    handlePhoneTypeChange(event) {
        this.personWrapper.phoneType = event.detail;
        this.hasFieldError.isFieldChanged = true;
    }

    /**Leay Year Check */
    isLeapYear(yearInput) {
        if ((0 == yearInput % 4 && 0 != yearInput % 100) || 0 == yearInput % 400) {
            return true;
        }
        return false;
    }

    /**Convert DOB to three different fields */
    parseDOB(dateOfBirthInput) {
        if (dateOfBirthInput) {
            let dob = new Date(dateOfBirthInput);
            this.dateOfBirth = {
                year: dob.getFullYear().toString(),
                month: dob.toLocaleString(LOCALE, { month: '2-digit' }).toString(),
                day: dob.toLocaleString(LOCALE, { day: '2-digit' }).toString()
            };
            this.setAllowedDays(this.dateOfBirth.month);
        }
    }

    parseDelegateDOB(birthYearInput) {
        if (birthYearInput) {
            this.dateOfBirth.year = birthYearInput;
        }
    }

    /**Set days based on month and year */
    setAllowedDays(monthInput) {
        let daysOptions = [];
        let allowedDays =
            monthInput !== '02'
                ? this.daysInMonth[parseInt(monthInput) - 1]
                : this.isLeapYear(this.dateOfBirth.year)
                ? this.daysInMonth[parseInt(monthInput) - 1] + 1
                : this.daysInMonth[parseInt(monthInput) - 1];
        for (let dayNumber = 1; dayNumber <= allowedDays; dayNumber++) {
            let formattedDayNumber = ('0' + dayNumber).slice(-2).toString();
            let dayOption = {
                label: formattedDayNumber,
                value: formattedDayNumber
            };
            daysOptions = [...daysOptions, dayOption];
        }
        this.daysList = daysOptions;
        if (allowedDays < parseInt(this.dateOfBirth.day)) {
            this.dateOfBirth.day = '01';
        }
    }

    /**Compare DOB with Today */
    isFutureDOB(month, day, year) {
        let currentDate = new Date();
        let formattedDOB = year + '-' + month + '-' + day;
        let dobInput = new Date(formattedDOB);
        return dobInput > currentDate ? true : false;
    }

    validatePhoneFormat(phoneInput) {
        let validFormat = /^[0-9]*$/;
        let isValid = false;
        if (validFormat.test(phoneInput)) {
            isValid = true;
        } else {
            isValid = false;
        }
        return isValid;
    }

    validateEmailFormat(emailValue) {
        let isValid = false;
        let regExpression = this.labels.EMAIL_PATTERN;
        let regExpressionInvalid = new RegExp(this.labels.EMAIL_INVALID_CHARACTERS);
        let invalidCharacterCheck = regExpressionInvalid.test(emailValue);
        if (!invalidCharacterCheck && emailValue.match(regExpression)) {
            isValid = true;
        } else {
            isValid = false;
        }
        return isValid;
    }

    showErrorInput(fieldInputId) {
        let errorInputElement = this.template.querySelector(`[data-id="${fieldInputId}"]`);
        errorInputElement.classList.add('profile-info-error-input');
    }

    removeErrorInput(fieldInputId) {
        let errorInputElement = this.template.querySelector(`[data-id="${fieldInputId}"]`);
        errorInputElement.classList.contains('profile-info-error-input')
            ? errorInputElement.classList.remove('profile-info-error-input')
            : 'Take a Break!!!';
    }

    showErrorMessage(fieldId) {
        let errorElement = this.template.querySelector(`[data-id="${fieldId}"]`);
        errorElement.classList.contains('slds-hide')
            ? errorElement.classList.remove('slds-hide')
            : 'Enjoy!!!';
    }

    removeErrorMessage(fieldId) {
        let errorElement = this.template.querySelector(`[data-id="${fieldId}"]`);
        errorElement.classList.add('slds-hide');
    }

    showMenuBar(event) {
        if (event.target.dataset.header) {
            this.dispatchEvent(
                new CustomEvent('shownavmenubar', {
                    detail: {
                        header: event.target.dataset.header
                    }
                })
            );
            this.isInitialized = false;
        }
    }

    navigateToHelpPage() {
        communityService.navigateToPage('help');
    }

    handleSave() {
        this.spinner.show();
        if (this.contact.Email != this.oldContactEmail) {
            changeEmail({ newEmail: this.contact.Email, userMode: this.userMode })
                .then((result) => {
                    this.handleUpdatePerson();
                })
                .catch((error) => {
                    this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                });
        } else {
            this.handleUpdatePerson();
        }
    }

    handleUpdatePerson() {
        updatePerson({ wrapperJSON: JSON.stringify(this.personWrapper) })
            .then((result) => {
                this.showToast(this.labels.DATA_UPDATE, this.labels.DATA_UPDATE, 'success');
                setTimeout(() => {
                    this.reInitializePage();
                }, 2000);
            })
            .catch((error) => {
                console.error('Thor:::', error);
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    reInitializePage() {
        this.initializeHasFieldError();
        this.initializeData();
        //this.spinner.hide();
        // communityService.navigateToPage('account-settings?profileInformation');
        // window.location.reload();
    }

    initializeHasFieldError() {
        this.hasFieldError = {
            isFNHasError: false,
            isLNHasError: false,
            isDOBHasError: false,
            isEmailHasError: false,
            isMPHasError: false,
            isDPHasError: false,
            isFieldChanged: false
        };
    }

    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }

    disconnectedCallback() {
        this.isInitialized = false;
    }
}
