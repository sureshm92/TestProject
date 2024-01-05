import { LightningElement, api, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
import AGE from '@salesforce/label/c.Age';
import DOB_YYYY from '@salesforce/label/c.Year_Placeholder';
import DOB_Month from '@salesforce/label/c.AccountSetting_Birth_Month';
import DOB_DD from '@salesforce/label/c.Date_Placeholder';
import DOB_Age from '@salesforce/label/c.Select';
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
    @track personWrapper = [];
    @track contact;
    @track oldContactEmail = '';
    @track delegateContact;
    userEmail = '';
    minorUserName = '';
    hasProfilePic = false;
    isInitialized = false;
    loadOnce = false;
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
        isFieldChanged: false,
        isAgeHasError: false
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
        DOB_YYYY,
        DOB_Month,
        DOB_Age,
        DOB_DD,
        AGE,
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

    dobConfigFormat = '';
    selectedAge = null;
    lastDay = 31;
    @track optionsDDList = [];
    @track optionsMMList = [];
    @track optionsYYYY = [];
    @track ageOpt = [];
    showDay = false;
    showMonth = true;
    ageInputDisabled = false;
    ageStart = '0';
    ageEnd = '150';

    daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    optiondateList() {
        var opt = [];
        var lastDay = this.lastDay;
        for (var i = 1; i <= lastDay; i++) {
            var x = i.toString();
            if (i < 10) x = '0' + x;
            opt.push({ label: x, value: x, isSelected: false });
            if (
                this.personWrapper &&
                this.personWrapper.birthDay &&
                this.personWrapper.birthDay == x
            ) {
                opt[x - 1].isSelected = true;
            }
        }
        this.optionsDDList = opt;
        if (onchange == 'onchange') {
            this.showDay = !this.showDay;
        }
    }
    monthsList() {
        var monthsList = [
            { label: JANUARY, value: '01', isSelected: false },
            { label: FEBRUARY, value: '02', isSelected: false },
            { label: MARCH, value: '03', isSelected: false },
            { label: APRIL, value: '04', isSelected: false },
            { label: MAY, value: '05', isSelected: false },
            { label: JUNE, value: '06', isSelected: false },
            { label: JULY, value: '07', isSelected: false },
            { label: AUGUST, value: '08', isSelected: false },
            { label: SEPTEMBER, value: '09', isSelected: false },
            { label: OCTOBER, value: '10', isSelected: false },
            { label: NOVEMBER, value: '11', isSelected: false },
            { label: DECEMBER, value: '12', isSelected: false }
        ];
        if (this.personWrapper && this.personWrapper.birthMonth) {
            monthsList.forEach((item, index) => {
                if (this.personWrapper.birthMonth == item.value) {
                    item.isSelected = true;
                }
            });
        }
        this.optionsMMList = monthsList;
        this.loadMMLeapYear();
    }
    yearsList() {
        let yearsOptions = [];
        let currentYear = parseInt(new Date().getFullYear());
        let earliestYear = 1900;
        for (var i = currentYear; i >= earliestYear; i--) {
            if (
                this.personWrapper &&
                this.personWrapper.birthYear &&
                this.personWrapper.birthYear == i.toString()
            ) {
                yearsOptions.push({ label: i.toString(), value: i.toString(), isSelected: true });
            } else {
                yearsOptions.push({ label: i.toString(), value: i.toString(), isSelected: false });
            }
        }
        this.optionsYYYY = yearsOptions;
        var format = this.dobConfigFormat;
        if (format != undefined) {
            this.showDay = format.includes('DD') ? true : false;
            this.showMonth = format.includes('MM') ? true : false;
        }
        //Onload of any othe DOB fields are Empty and onchange of other fields with DOB empty disable the save btn
        if (this.dobConfigFormat == 'DD-MM-YYYY') {
            if (
                !this.personWrapper.birthDay ||
                !this.personWrapper.birthMonth ||
                !this.personWrapper.birthYear
            ) {
                this.hasFieldError.isDOBHasError = true;
            }
        } else if (this.dobConfigFormat == 'MM-YYYY') {
            if (!this.personWrapper.birthYear || !this.personWrapper.birthMonth) {
                this.hasFieldError.isDOBHasError = true;
            }
        } else if (this.dobConfigFormat == 'YYYY') {
            if (!this.personWrapper.birthYear) {
                this.hasFieldError.isDOBHasError = true;
            }
        }
        this.setLastDay();

        if (!this.showDay) {
            this.setMinMaxAge();
        }

        // write some additional logic
    }
    loadMMLeapYear() {
        var maxDayMonths = ['01', '03', '05', '07', '08', '10', '12'];
        var minDayMonths = ['04', '06', '09', '11'];
        var personWrapper = this.personWrapper;

        if (maxDayMonths.includes(personWrapper.birthMonth)) {
            this.lastDay = 31;
        } else if (minDayMonths.includes(personWrapper.birthMonth)) {
            this.lastDay = 30;
        }
        this.setLastDay();
    }
    setLastDay() {
        var personWrapper = this.personWrapper;
        if (personWrapper.birthMonth == '02') {
            if (personWrapper.birthMonth == '----' || this.isLeapYear()) {
                this.lastDay = 29;
            } else {
                this.lastDay = 28;
            }
        }
        if (parseInt(personWrapper.birthDay) > this.lastDay) {
            var lastDayval = this.lastDay;
            personWrapper.birthDay = lastDayval.toString();
            this.personWrapper = personWrapper;
        }
        var onchange = 'onchange';
        this.optiondateList(onchange);
    }

    setMinMaxAge() {
        var personWrapper = this.personWrapper;
        var format = this.dobConfigFormat;
        var partDOB = '';
        if (format != 'DD-MM-YYYY') {
            if (format == 'MM-YYYY') {
                if (personWrapper.birthYear && personWrapper.birthMonth) {
                    partDOB =
                        personWrapper.birthYear +
                        '-' +
                        personWrapper.birthMonth +
                        '-' +
                        this.lastDay;
                }
            } else if (format == 'YYYY') {
                if (personWrapper.birthYear) {
                    partDOB = personWrapper.birthYear + '-12-31';
                }
            }
            if (partDOB && !partDOB.includes('--')) {
                var dob = new Date(partDOB.replace(/-/g, '/'));
                var month_diff = Date.now() - dob.getTime();
                var age_dt = new Date(month_diff);
                var year = age_dt.getUTCFullYear();
                if (year - 1970 >= 0) {
                    var age = Math.abs(year - 1970);
                    this.ageStart = age;
                    var endAge = age;
                    if (
                        (dob.getMonth() == new Date().getMonth() &&
                            dob.getDate() != new Date().getDate()) ||
                        format == 'YYYY'
                    ) {
                        endAge++;
                    }
                    this.ageEnd = endAge;
                    this.setAge();
                } else {
                    this.ageStart = '0';
                    this.ageEnd = '0';
                    this.setAge();
                }
            }
        }
    }
    setAge() {
        var opt = [];
        var ageStart = parseInt(this.ageStart);
        var ageEnd = parseInt(this.ageEnd);
        var selectedAgeNotInOptions = false;
        for (var i = ageStart; i <= ageEnd; i++) {
            if (
                this.personWrapper &&
                this.personWrapper.age &&
                (this.personWrapper.age == ageStart || this.personWrapper.age == ageEnd)
            ) {
                selectedAgeNotInOptions = true;
                opt.push({ label: i.toString(), value: i.toString(), isSelected: true });
            } else {
                opt.push({ label: i.toString(), value: i.toString(), isSelected: false });
            }
        }
        this.ageOpt = opt;
        if (!selectedAgeNotInOptions) {
            this.personWrapper.age = null;
            this.selectedAge = null;
            this.handleAgeErrorMessage();
        }
    }

    renderedCallback() {
        this.spinner =  this.template.querySelector('c-web-spinner');
        if (!this.loadOnce) {
            this.template.querySelector('c-web-spinner')?.show();
            this.initializeData();
            this.loadOnce = true;
        }
    }
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
                this.dobConfigFormat = this.initData.consentPreferenceData.studySiteYOBFormat;
                var participantselectedage =
                    this.personWrapper.age != undefined ? this.personWrapper.age.toString() : '';
                if (this.dobConfigFormat == 'DD-MM-YYYY') {
                    this.ageInputDisabled = true;
                } else {
                    this.ageInputDisabled = false;
                }
                this.selectedAge = participantselectedage;
                if (this.userMode === 'Participant') {
                    this.isAdult = initialData.participant.Adult__c;
                }
                /**Delegate */
                // DEl switching to Participant
                if (communityService.getCurrentCommunityMode().currentDelegateId) {
                    this.isDelegate = true;
                    this.isMobilePhoneInvalid = true;
                    this.userId = communityService.getCurrentCommunityMode().currentDelegateId;
                    if (this.userMode === 'Participant') {
                        if (
                            initialData.participant.Adult__c &&
                            initialData.delegateUserName != null
                        ) {
                            this.userEmail = initialData.delegateUserName.Username;
                        }
                    }
                } else {
                    // Participant,Del self view, Multi Role
                    this.isDelegate = false;
                    this.userId = initialData.myContact.Id;
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
                this.yearsList();
                this.monthsList();
                this.optiondateList();
                if (this.dobConfigFormat == 'DD-MM-YYYY') {
                    this.participantAge();
                }
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
    get shortContainerClass1() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_3-of-8 slds-p-vertical_x-small'
            : 'slds-form-element slds-medium-size_1-of-7 slds-p-vertical_x-small';
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

    get doGetAgeClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-col slds-size_1-of-3 slds-p-right_none slds-p-left_x-small'
                : 'slds-col slds-size_1-of-3 slds-p-left_none slds-p-right_x-small'
            : this.isRTL
            ? 'slds-col slds-size_1-of-3 slds-p-right_none slds-p-left_x-small'
            : 'slds-col slds-size_1-of-3 slds-p-left_none slds-p-right_x-small customMargin';
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
                ? 'primaryBtn slds-button slds-button_brand save-button save-button-disabled full-width'
                : 'primaryBtn slds-button slds-button_brand save-button full-width'
            : this.isSaveDisabled
            ? 'primaryBtn slds-button slds-button_brand save-button save-button-disabled'
            : 'primaryBtn slds-button slds-button_brand save-button';
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
    get delSelfView() {
        if (this.isDelegate || (!this.isDelegate && !this.personWrapper.showBirthDate)) {
            return false;
        }
    }
    get dobForDelegate() {
        return !this.isDelegate && !this.personWrapper.showBirthDate ? true : false;
    }
    get dobForParticipant() {
        return !this.isDelegate && this.personWrapper.showBirthDate ? true : false;
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
            !this.hasFieldError.isAgeHasError &&
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
        if (this.personWrapper.birthMonth != event.detail) {
            this.personWrapper.birthMonth = event.detail;
            this.setAllowedDays(this.personWrapper.birthMonth);
            var studyDobFormat = this.dobConfigFormat;
            if (studyDobFormat == 'DD-MM-YYYY') {
                this.participantAge();
                this.handleDOBErrorMessage();
            } else {
                this.personWrapper.age = null;
                this.selectedAge = null;
                this.setMinMaxAge();
                this.handleDOBErrorMessage();
                this.handleAgeErrorMessage();
            }
        }
    }

    handleDayChange(event) {
        if (this.personWrapper.birthDay != event.detail) {
            this.personWrapper.birthDay = event.detail;
            var studyDobFormat = this.dobConfigFormat;
            if (studyDobFormat == 'DD-MM-YYYY') {
                this.participantAge();
                this.handleDOBErrorMessage();
            }
        }
    }

    handleYearChange(event) {
        if (this.personWrapper.birthYear != event.detail) {
            this.personWrapper.birthYear = event.detail;
            this.setAllowedMonths(this.personWrapper.birthYear);
            this.setAllowedDays(this.personWrapper.birthMonth);
            if (this.dobConfigFormat == 'DD-MM-YYYY') {
                this.participantAge();
                this.handleDOBErrorMessage();
            } else {
                this.personWrapper.age = null;
                this.selectedAge = null;
                this.setMinMaxAge();
                this.handleDOBErrorMessage();
                this.handleAgeErrorMessage();
            }
        }
    }

    handleDOBErrorMessage() {
        if (this.dobConfigFormat == 'YYYY') {
            if (this.personWrapper.birthYear) {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = false;
            } else {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = true;
            }
        } else if (this.dobConfigFormat == 'MM-YYYY') {
            if (this.personWrapper.birthYear && this.personWrapper.birthMonth) {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = false;
            } else {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = true;
            }
        } else if (this.dobConfigFormat == 'DD-MM-YYYY') {
            if (
                this.personWrapper.birthYear &&
                this.personWrapper.birthMonth &&
                this.personWrapper.birthDay
            ) {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = false;
            } else {
                this.hasFieldError.isFieldChanged = true;
                this.hasFieldError.isDOBHasError = true;
            }
        }
    }
    handleAgeErrorMessage() {
        let delSelfView = !this.isDelegate && !this.personWrapper.showBirthDate ? true : false;
        if (!delSelfView) {
            if (
                this.dobConfigFormat == 'MM-YYYY' &&
                this.personWrapper.birthYear &&
                this.personWrapper.birthMonth
            ) {
                if (
                    this.selectedAge == null ||
                    this.selectedAge == undefined ||
                    this.selectedAge == ''
                ) {
                    this.hasFieldError.isFieldChanged = true;
                    this.hasFieldError.isAgeHasError = true;
                } else {
                    this.hasFieldError.isFieldChanged = true;
                    this.hasFieldError.isAgeHasError = false;
                }
            }
            if (this.dobConfigFormat == 'YYYY' && this.personWrapper.birthYear) {
                if (
                    this.selectedAge == null ||
                    this.selectedAge == undefined ||
                    this.selectedAge == ''
                ) {
                    this.hasFieldError.isFieldChanged = true;
                    this.hasFieldError.isAgeHasError = true;
                } else {
                    this.hasFieldError.isFieldChanged = true;
                    this.hasFieldError.isAgeHasError = false;
                }
            }
        }
    }
    handleAgeChange(event) {
        let ageVal = event.detail;
        this.selectedAge = event.detail;
        var num = parseFloat(this.selectedAge).toFixed(2);
        var personWrapper = this.personWrapper;
        personWrapper.age = num;
        this.personWrapper = personWrapper;
        let ageOptions = this.ageOpt;
        let ageOptSelected = [];
        if (this.ageOpt) {
            ageOptions.forEach((item, index) => {
                if (personWrapper && personWrapper.age && item.value == personWrapper.age) {
                    ageOptSelected.push({ label: item.label, value: item.value, isSelected: true });
                } else {
                    ageOptSelected.push({
                        label: item.label,
                        value: item.value,
                        isSelected: false
                    });
                }
            });
            this.ageOpt = ageOptSelected;
        }
        this.handleDOBErrorMessage();
        this.handleAgeErrorMessage();
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

    /**Set days based on month and year */
    setAllowedDays(monthInput) {
        let daysOptions = [];
        let currentDate = new Date();
        let date = currentDate.getDate();
        let year = currentDate.getFullYear();
        let month = currentDate.getMonth() + 1;
        let allowedDays;
        if (this.personWrapper.birthYear == year && monthInput == month) {
            allowedDays = date;
        } else {
            allowedDays =
                monthInput !== '02'
                    ? this.daysInMonth[parseInt(monthInput) - 1]
                    : this.isLeapYear(this.personWrapper.birthYear)
                    ? this.daysInMonth[parseInt(monthInput) - 1] + 1
                    : this.daysInMonth[parseInt(monthInput) - 1];
        }
        for (let dayNumber = 1; dayNumber <= allowedDays; dayNumber++) {
            let formattedDayNumber = ('0' + dayNumber).slice(-2).toString();
            let daySelected = false;
            if (
                this.personWrapper &&
                this.personWrapper.birthDay &&
                this.personWrapper.birthDay == formattedDayNumber
            ) {
                daySelected = true;
            }
            let dayOption = {
                label: formattedDayNumber,
                value: formattedDayNumber,
                isSelected: daySelected
            };
            daysOptions = [...daysOptions, dayOption];
        }

        this.optionsDDList = daysOptions;
        this.lastDay = allowedDays;
        if (parseInt(this.personWrapper.birthDay) > this.lastDay) {
            this.personWrapper.birthDay = '01';
        }
    }
    setAllowedMonths(yearInput) {
        let optionsMMList1 = [];
        const currentDate = new Date();
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth() + 1;
        let monthInSelectedOptions = false;
        let currentMonth = this.personWrapper.birthMonth;
        if (yearInput == year) {
            for (let monthNumber = 1; monthNumber <= month; monthNumber++) {
                for (var i = monthNumber - 1; i < this.optionsMMList.length; i++) {
                    let monthOption = {
                        label: this.optionsMMList[i].label,
                        value: this.optionsMMList[i].value,
                        isSelected: this.optionsMMList[i].isSelected
                    };
                    if (currentMonth && currentMonth == monthOption.value) {
                        monthInSelectedOptions = true;
                    }
                    optionsMMList1 = [...optionsMMList1, monthOption];
                    break;
                }
            }
            if (!monthInSelectedOptions) {
                //if current Month is May and previous one / backend one is future month
                this.personWrapper.birthMonth = '';
                this.personWrapper.birthDay = '';
                this.ageOpt = [];
            }
            this.optionsMMList = optionsMMList1;
        } else {
            this.monthsList();
        }
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
        this.personWrapper.dateBirth = '';
        // Participnat part of Multiple studies (DD-MM-YYYY and MM-YYYY) and select the future day nullify the future dates at backend
        if (this.dobConfigFormat == 'MM-YYYY') {
            var personWrapper = this.personWrapper;
            const currentDate = new Date();
            const year = currentDate.getFullYear();
            const month = currentDate.getMonth() + 1;
            const day = currentDate.getDate();
            if (
                personWrapper.birthYear == year &&
                personWrapper.birthMonth == month &&
                this.personWrapper.birthDay > day
            ) {
                this.personWrapper.birthDay = '';
            }
        } else if (this.dobConfigFormat == 'YYYY') {
            var personWrapper = this.personWrapper;
            const currentDate = new Date();
            const year = currentDate.getFullYear();
            const month = currentDate.getMonth() + 1;
            const day = currentDate.getDate();
            if (
                personWrapper.birthYear == year &&
                personWrapper.birthMonth &&
                personWrapper.birthMonth == month &&
                personWrapper.birthDay &&
                this.personWrapper.birthDay > day
            ) {
                this.personWrapper.birthDay = '';
            } else if (
                personWrapper.birthYear == year &&
                personWrapper.birthMonth &&
                personWrapper.birthMonth > month
            ) {
                this.personWrapper.birthMonth = '';
                this.personWrapper.birthDay = '';
            }
        }
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
            isFieldChanged: false,
            isAgeHasError: false
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
    //dob changes
    participantAge() {
        //alert('this.parti');
        var studyDobFormat = this.dobConfigFormat;
        var personWrapperDob = this.personWrapper;
        console.log(
            personWrapperDob.birthYear +
                '-' +
                personWrapperDob.birthMonth +
                '-' +
                personWrapperDob.birthDay
        );
        if (
            studyDobFormat == 'DD-MM-YYYY' &&
            personWrapperDob.birthYear != undefined &&
            personWrapperDob.birthYear != null &&
            personWrapperDob.birthYear != '' &&
            personWrapperDob.birthMonth != undefined &&
            personWrapperDob.birthMonth != null &&
            personWrapperDob.birthMonth != '' &&
            personWrapperDob.birthDay != undefined &&
            personWrapperDob.birthDay != null &&
            personWrapperDob.birthDay != ''
        ) {
            var dob = new Date(
                personWrapperDob.birthYear +
                    '-' +
                    personWrapperDob.birthMonth +
                    '-' +
                    personWrapperDob.birthDay
            );
            //calculate month difference from current date in time
            var month_diff = Date.now() - dob.getTime();
            //convert the calculated difference in date format
            var age_dt = new Date(month_diff);
            //extract year from date
            var year = age_dt.getUTCFullYear();
            //now calculate the age of the user
            var age = Math.abs(year - 1970);
            var num = parseFloat(age).toFixed(2);
            personWrapperDob.age = num;
            this.selectedAge = age.toString();
            this.personWrapper = personWrapperDob;
        } else {
            this.selectedAge = null;
            personWrapperDob.age = null;
            this.personWrapper = personWrapperDob;
        }
    }
}