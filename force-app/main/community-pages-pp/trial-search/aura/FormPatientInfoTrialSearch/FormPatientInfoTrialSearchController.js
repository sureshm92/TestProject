/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        component.find('spinner').show();
        var device = $A.get('$Browser.formFactor');
        device == 'PHONE' ? component.set('v.mobile', true) : component.set('v.mobile', false);
        let rtl_language = $A.get('$Label.c.RTL_Languages');
        let paramLanguage = communityService.getUrlParameter('language');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        var opt = [];
        for (var i = parseInt(new Date().getFullYear()); i >= 1900; i--) {
            opt.push({ label: i.toString(), value: i.toString() });
        }
        component.set('v.optionsYYYY', opt);
        var formData = component.get('v.formData');
        const val = [
            {
                label: $A.get('$Label.c.trialSearch_me'),
                value: 'Me'
            } /*,
            { label: $A.get('$Label.c.trialSearch_Someone_else'), value: 'Someone else' }*/
        ];

        component.set('v.sendForList', val);
        var states = formData.statesByCountryMap['US'];
        component.set('v.statesLVList', states);
        communityService.executeAction(
            component,
            'getInitData',
            {
                userMode: 'Participant'
            },
            function (initData) {
                component.set('v.contactInfo', JSON.parse(initData).myContact);
                component.set(
                    'v.isDisclaimer',
                    JSON.parse(initData).myContact.IQVIA_Contact_info_storage_consent__c
                );
                component.set('v.preferenceData', JSON.parse(initData).consentPreferenceData);
                component.set(
                    'v.isStorage',
                    JSON.parse(initData).myContact.IQVIA_Contact_info_storage_consent__c
                );
                component.find('spinner').hide();
            }
        );
        let copyParticipant = JSON.parse(JSON.stringify(component.get('v.participant')));
        component.set('v.participantInfo', copyParticipant);
    },

    doCheckFields: function (component, event, hepler) {
        var participant = component.get('v.participantInfo');
        // var stateRequired = component.get('v.statesLVList')[0];
        var numbers = /^[0-9]*$/;
        var phoneField = component.find('pField2');
        let isValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Email__c &&
            component.get('v.sendFor') !== '' &&
            component.find('emailInput').get('v.validity').valid;
        console.log('VALIDITY' + isValid);

        /* if (!participant.Mailing_State_Code__c && participant.Mailing_Country_Code__c == 'US') {
            isValid = false;
        }*/

        if (isValid) {
            component.set('v.isValid', true);
            if (numbers.test(participant.Phone__c) && participant.Phone__c) {
                phoneField.setCustomValidity('');
                phoneField.reportValidity();
            }
        } else {
            if (!numbers.test(participant.Phone__c) || !participant.Phone__c) {
                if (!participant.Phone__c) {
                    phoneField.setCustomValidity($A.get('$Label.c.PP_Phone_Mandatory'));
                    phoneField.reportValidity();
                } else {
                    phoneField.setCustomValidity($A.get('$Label.c.PP_MessagePatternMismatch'));
                    phoneField.reportValidity();
                }
            } else {
                phoneField.setCustomValidity('');
                phoneField.reportValidity();
            }
            component.set('v.isValid', false);
        }
    },
    handleHomePhoneValidation: function (component, event) {
        var inputValue = event.getSource().get('v.value');
        var phoneField = component.find('pField2');
        var numbers = /^[0-9]*$/;
        if (inputValue === '') {
            phoneField.setCustomValidity($A.get('$Label.c.PP_Phone_Mandatory'));
        }
        if (!numbers.test(inputValue) && inputValue !== '') {
            phoneField.setCustomValidity($A.get('$Label.c.PP_MessagePatternMismatch'));
            component.set('v.isValid', false);
        } else {
            phoneField.setCustomValidity(''); // reset custom error
            component.set('v.isValid', true);
        }
        phoneField.reportValidity();
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var participant = component.get('v.participantInfo');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        // component.set('v.participant.Mailing_State_Code__c', null);
        component.checkFields();
    },

    onClickDisclaimer: function (component, event, helper) {
        component.set('v.isDisclaimer', !component.get('v.isDisclaimer'));
    },
    onClickDisclaimerchange: function (component, event, helper) {
        component.set(
            'v.isDisclaimer',
            component.get('v.contactInfo.IQVIA_Contact_info_storage_consent__c')
        );
    },
    changeFor: function (component, event, helper) {
        if (component.get('v.sendFor') === 'Me') {
            let copyParticipant = JSON.parse(JSON.stringify(component.get('v.participant')));
            component.set('v.participantInfo', copyParticipant);
            console.log('copyParticipant::' + copyParticipant);
        } else {
            let participant = {
                sobjectType: 'Participant__c',
                First_Name__c: '',
                Last_Name__c: '',
                Date_of_Birth__c: '',
                Birth_Year__c: '',
                Gender__c: '',
                Phone__c: '',
                Phone_Type__c: '',
                Email__c: '',
                Mailing_Country_Code__c: '',
                Mailing_State_Code__c: '',
                Mailing_Zip_Postal_Code__c: ''
            };
            component.set('v.participantInfo', participant);
        }
    },
    OpenPPPopup: function (component) {
        component.set('v.showPpPopup', true);
    },
    closePpPopup: function (component) {
        component.set('v.showPpPopup', false);
    },
    navigateToAccoutSettingsPage: function (component) {
        localStorage.setItem('Cookies', 'Accepted');
        window.open('account-settings?profileInformation', '_blank');
        window.focus();
    }
});
