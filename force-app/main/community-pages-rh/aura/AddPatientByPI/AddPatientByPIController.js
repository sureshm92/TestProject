/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            let ssId = communityService.getUrlParameter('ssId');

            component.find('spinner').show();
            communityService.executeAction(component, 'getInitData', {
                ssId: ssId
            }, function (formData) {
                component.set('v.ctp', formData.ctp);
                component.set('v.ss', formData.ss);
                component.set('v.formData', formData);
                component.set('v.initialized', true);
                component.set('v.userLanguage', formData.userLanguage);
                console.log('LANGUAGE', component.get('v.userLanguage'));
                window.setTimeout(
                    $A.getCallback(function () {
                        helper.initData(component);
                    }), 100
                );
            }, null, function () {
                component.find('spinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doCancel: function (component) {
        communityService.navigateToHome();
    },

    doSaveAndExit: function (component, event, helper) {
        helper.createParticipant(component, function () {
            communityService.navigateToHome();
        })
    },

    doSaveAndNew: function (component, event, helper) {
        helper.createParticipant(component, function () {
            helper.initData(component);
            helper.setDelegate(component);
            component.find('editForm').refreshEmailInput();
        })
    },

    doCheckfields: function (component, event, helper) {
        helper.checkFields(component,event,helper);
    },

    doCheckDateOfBith: function (component, event, helper) {
        component.set('v.isDelegateValid', false);
        helper.checkParticipantNeedsGuardian(component, helper, event);
        $A.enqueueAction(component.get('c.doCheckfields'));
        var participant = component.get('v.participant');
        component.set('v.participant', participant);
        console.log('EMEil', participant.Email__c);
        console.log('ADult', participant.Adult__c);
    },

    doNeedsGuardian: function (component, event, helper) {
        component.set('v.participant.Health_care_proxy_is_needed__c', !component.get('v.participant.Health_care_proxy_is_needed__c'));

        let participant = component.get('v.participant');
        component.set('v.needsGuardian', participant.Health_care_proxy_is_needed__c);

        if (participant.Health_care_proxy_is_needed__c) {
            helper.setDelegate(component);
            console.log('editForm checkFields');
        } else {
            component.set('v.isDelegateValid', false);
            component.set('v.useThisDelegate', true);
            let editForm = component.find('editForm');
            editForm.checkFields();
            component.set('v.emailDelegateRepeat', '');
        }
    },
    
    approveDelegate:function(component, event, helper) {
        var ddi = component.get('v.delegateDuplicateInfo');
        var partDel = component.get('v.participantDelegate');
        if(ddi.contactPhoneType) partDel.Phone_Type__c = ddi.contactPhoneType;
        if(ddi.contactPhoneNumber) partDel.Phone__c = ddi.contactPhoneNumber;
        component.set('v.participantDelegate', partDel);
        component.set('v.useThisDelegate', true);
        helper.checkFields(component,event,helper, true);
    },

    doRefreshParticipant: function (component, event, helper) {
        var participant = component.get('v.participant');
        component.set('v.participant', participant);
    },

    doCreateUserInv: function (component) {
        component.set('v.createUsers', !component.get('v.createUsers'));
    },

    doNotContact: function (component) {
        component.set('v.doNotContact', !component.get('v.doNotContact'));
        if (component.get('v.doNotContact')) component.set('v.createUsers', false);
    }

})
