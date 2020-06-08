({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId) component.set('v.isDelegate', true);

        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
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
        }, null, function () {
            component.find('spinner').hide();
        })
    },
    doSwitchOptInCookies: function (component, event, helper) {
        let initData = component.get('v.initData');
        communityService.executeAction(component, 'changeOptInCookies', {
            rrCookieAllowed: initData.myContact.RRCookiesAllowedCookie__c,
            rrLanguageAllowed: initData.myContact.RRLanguageAllowedCookie__c
        }, function () {
            location.reload();
        });
    },

    doSubmitQuestion: function (component, event, helper) {
        let description = component.get('v.privacyFormText');
        if (!description) {
            communityService.showToast('warning', 'warning', $A.get('$Label.c.TST_Complete_Your_Question'));
            return;
        }

        component.set('v.showSpinner', true);
        communityService.executeAction(component, 'createCase', {
            description: description,
            type: 'Privacy'
        }, function () {
            communityService.showToast('success', 'success', $A.get('$Label.c.TST_Thank_you_for_submitting_your_question'));
            component.set('v.privacyFormText', '');
        }, null, function () {
            component.set('v.showSpinner', false);
        })
    },
});