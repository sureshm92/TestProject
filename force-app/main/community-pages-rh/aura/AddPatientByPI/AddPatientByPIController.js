/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        
        if(!communityService.isDummy()) {
            let ssId = communityService.getUrlParameter('ssId');
            
            component.find('spinner').show();
            helper.checkCommunity(component, event, helper);
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
        component.find('delegate-phone').focus();
        component.find('delegate-phone').blur();
        component.set('v.useThisDelegate', true);
        //helper.checkFields(component,event,helper, true);
    },
    
    doRefreshParticipant: function (component, event, helper) {
        var participant = component.get('v.participant');
        component.set('v.participant', participant);
    },
    
    doCreateUserInv: function (component) {
        component.set('v.createUsers', !component.get('v.createUsers'));   
    },
    
    doContact : function (component){
        component.set('v.doContact', !component.get('v.doContact'));
        if(!component.get('v.doContact')){
            component.set('v.createUsers',false);
        }
    },
    
    doContactEmail : function (component){
        component.set('v.isEmail', !component.get('v.isEmail'));
    },
    
    doContactPhone : function (component){
        component.set('v.isPhone', !component.get('v.isPhone'));
    },
    
    doContactSMS : function(component){
        component.set('v.isSMS',!component.get('v.isSMS'));
    }
    
})