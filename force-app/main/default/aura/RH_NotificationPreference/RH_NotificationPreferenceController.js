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
            component.set('v.contact', initData.myContact);
            component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
            
            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
    
    doSwitchOptInEmail: function (component, event, helper) {
        let initData = component.get('v.initData');
        let optInEmail = component.get('v.optInEmail');
        communityService.executeAction(component, 'changeOptInEmail', {
            participantOptInStatusEmail: optInEmail,
            hcpOptInPatientEmail: initData.myContact.HCP_Opt_In_Patient_Status_Emails__c,
            hcpOptInStudyEmail: initData.myContact.HCP_Opt_In_Study_Emails__c,
            hcpOptInRefStatusEmail: initData.myContact.HCP_Opt_In_Referral_Status_Emails__c
        }, function () {});
    },
})