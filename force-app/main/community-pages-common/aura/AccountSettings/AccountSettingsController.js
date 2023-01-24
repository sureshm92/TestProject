({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId)
            component.set('v.isDelegate', true);

        communityService.executeAction(
            component,
            'getInitData',
            {
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                let initData = JSON.parse(returnValue);
                initData.password = {
                    old: '',
                    new: '',
                    reNew: ''
                };

                component.set('v.initData', initData);
                component.set('v.contactChanged', initData.contactChanged);
                component.set('v.personWrapper', initData.contactSectionData.personWrapper);
                component.set('v.contactSectionData', initData.contactSectionData);
                component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
                component.set('v.optInSMS', initData.contactSectionData.personWrapper.optInSMS);

                component.set('v.contact', initData.myContact);
                component.set('v.currentEmail', initData.myContact.Email);

                component.set('v.isInitialized', true);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },

    doChangeEmail: function (component, event, helper) {
        let initData = component.get('v.initData');
        let newEmail = initData.myContact.Email;
        if (!newEmail) {
            communityService.showToast(
                'error',
                'error',
                $A.get('$Label.c.TST_Email_can_t_be_empty')
            );
            return;
        }
        let oldEmail = component.get('v.currentEmail');
        if (newEmail === oldEmail) {
            communityService.showToast('waring', 'warning', $A.get('$Label.c.TST_Emails_are_same'));
            return;
        }

        component.set('v.showSpinner', true);
        communityService.executeAction(
            component,
            'changeEmail',
            {
                newEmail: newEmail,
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                component.set('v.currentEmail', newEmail);
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.TST_Your_email_address_has_been_updated')
                );
            },
            null,
            function () {
                component.set('v.showSpinner', false);
            }
        );
    },

    doChangePassword: function (component, event, helper) {
        component.set('v.showSpinner', true);
        let initData = component.get('v.initData');

        communityService.executeAction(
            component,
            'changePassword',
            {
                newPassword: initData.password.new,
                verifyNewPassword: initData.password.reNew,
                oldPassword: initData.password.old
            },
            function (returnValue) {
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.TST_Your_password_has_been_changed_successfully')
                );
                let initData = component.get('v.initData');
                component.set('v.initData.password', {
                    old: '',
                    new: '',
                    reNew: ''
                });
            },
            null,
            function () {
                component.set('v.showSpinner', false);
            }
        );
    },

    doSwitchOptInEmail: function (component, event, helper) {
        let initData = component.get('v.initData');
        let optInEmail = component.get('v.optInEmail');
        communityService.executeAction(
            component,
            'changeOptInEmail',
            {
                participantOptInStatusEmail: optInEmail,
                hcpOptInPatientEmail: initData.myContact.HCP_Opt_In_Patient_Status_Emails__c,
                hcpOptInStudyEmail: initData.myContact.HCP_Opt_In_Study_Emails__c,
                hcpOptInRefStatusEmail: initData.myContact.HCP_Opt_In_Referral_Status_Emails__c,
                userMode: component.get('v.userMode')
            },
            function () {}
        );
    },

    doSwitchOptInSMS: function (component, event, helper) {
        let optInSMS = component.get('v.optInSMS');
        communityService.executeAction(
            component,
            'changeOptInSMS',
            {
                participantOptInStatusSMS: optInSMS,
                userMode: component.get('v.userMode')
            },
            function () {
                component.find('contact-info-section').scrollOnMobileField(optInSMS);
            }
        );
    },

    doSwitchOptInCookies: function (component, event, helper) {
        let initData = component.get('v.initData');
        communityService.executeAction(
            component,
            'changeOptInCookies',
            {
                rrCookieAllowed: initData.myContact.RRCookiesAllowedCookie__c,
                rrLanguageAllowed: initData.myContact.RRLanguageAllowedCookie__c
            },
            function () {
                communityService.reloadPage();
            }
        );
    },

    doSubmitQuestion: function (component, event, helper) {
        let description = component.get('v.privacyFormText');
        if (!description) {
            communityService.showToast(
                'warning',
                'warning',
                $A.get('$Label.c.TST_Complete_Your_Question')
            );
            return;
        }

        component.set('v.showSpinner', true);
        communityService.executeAction(
            component,
            'createCase',
            {
                description: description,
                type: 'Privacy'
            },
            function () {
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.TST_Thank_you_for_submitting_your_question')
                );
                component.set('v.privacyFormText', '');
            },
            null,
            function () {
                component.set('v.showSpinner', false);
            }
        );
    },

    checkUpdate: function (component, event, helper) {
        component.set('v.isUpdated', true);
    },

    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');
        component.set('v.optInEmail', personWrapper.optInEmail);
        component.set('v.optInSMS', personWrapper.optInSMS);
        component.set('v.personWrapper', personWrapper);
    },

    checkPswdStrength: function (component, event, helper) {
        var caps = event.getParam('caps');
        component.set('v.caps', caps);
        var small = event.getParam('small');
        component.set('v.small', small);
        var numbers = event.getParam('numbers');
        component.set('v.numbers', numbers);
        var length = event.getParam('length');
        component.set('v.length', length);
        var special = event.getParam('special');
        component.set('v.special', special);
    }
});
