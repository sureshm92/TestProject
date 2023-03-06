/**
 * Created by Leonid Bartenev
 */
 ({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            let ssId = communityService.getUrlParameter('ssId');
			
            component.find('spinner').show();
            helper.checkCommunity(component, event, helper);
            communityService.executeAction(
                component,
                'getInitData',
                {
                    ssId: ssId
                },
                function (formData) {
                    component.set('v.ctp', formData.ctp);
                    component.set('v.ss', formData.ss);
                    component.set('v.formData', formData);
                    component.set('v.initialized', true);
                    component.set('v.userLanguage', formData.userLanguage);
                    if (
                        formData.ss.Study_Site_Type__c == 'Hybrid' ||
                        formData.ss.Study_Site_Type__c == 'Virtual'
                    ) {
                        component.set('v.createUserForDelegate', false);
                    } else {
                        component.set('v.createUserForDelegate', true);
                    }

                    console.log('LANGUAGE', component.get('v.userLanguage'));
                    window.setTimeout(
                        $A.getCallback(function () {
                            helper.initData(component);
                        }),
                        100
                    );
                },
                null,
                function () {
                    component.find('spinner').hide();
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },
    
    checkMandatory: function (component, event, helper) {
        component.find('consent-Manager').validateConsent();
        var formInputs =  component.find("dataDiv1").find({instancesOf : "lightning:select"});
        var formInputs2 = component.find("dataDiv1").find({instancesOf : "lightning:input"});

        for(var i = 0; i < formInputs.length; i++){
            formInputs[i].showHelpMessageIfInvalid();
        }
        for(var i = 0; i < formInputs2.length; i++){
            if(formInputs2[i] && formInputs2[i].get('v.value')) {
                formInputs2[i].set('v.value',  formInputs2[i].get('v.value').trim());
            }
           formInputs2[i].showHelpMessageIfInvalid();
        }
        var selectYr = component.find("yearField");
        if(selectYr){
            helper.checkGuardianAge(component, event, helper);
        }
        /*var conCheck = component.find("checkbox-Contact");
        if(!document.getElementById("checkbox-unique-id-76").checked){
            document.getElementById("cnLabel").classList.add("chErr");
            document.getElementById("cnLabelErr").classList.remove("slds-hide");
        }*/
        let editForm = component.find('editForm');
        editForm.resetDateInput();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: $A.get("$Label.c.PIR_addParticipantFillMandatory"),
            type : 'error'
        });
        var mainDiv =  document.getElementsByClassName("fieldsDiv");
        mainDiv[0].focus();           
        toastEvent.fire();
        const myTimeout = setTimeout(function(){
            mainDiv[0].focus();           
        }, 50);
    },  

    doCheckYearOfBith: function (component, event, helper) {
        helper.checkGuardianAge(component, event, helper);
    },

    doCancel: function(component){ 
        if(communityService.getUrlParameter('participantVeiwRedirection')=='true'){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/my-referrals" });
        urlEvent.fire();
        }else{
        communityService.navigateToHome();
        }
    },

    doSaveAndExit: function (component, event, helper) {
        /**  helper.createParticipant(component, function () {
              // communityService.navigateToHome();
              var urlEvent = $A.get("e.force:navigateToURL");
              urlEvent.setParams({ "url": "/my-referrals" });  
              urlEvent.fire(); 
          }); **/
          component.set('v.doSaveNew',false);
           helper.createParticipants(component);console.log('dosaveandexit'); 
    },
  
    doSaveAndNew: function (component, event, helper) {
         /** helper.createParticipant1(component, function () {
              var mainDiv =  document.getElementsByClassName("fieldsDiv");
              mainDiv[0].focus();
              helper.initData(component);
              helper.setDelegate(component);
              component.find('editForm').refreshEmailInput();
          });**/
           component.set('v.doSaveNew',true);
           helper.createParticipants(component);console.log('dosaveandnew'); 
    },

    doCheckfields: function (component, event, helper) {
        helper.checkFields(component, event, helper);
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
        component.set(
            'v.participant.Health_care_proxy_is_needed__c',
            !component.get('v.participant.Health_care_proxy_is_needed__c')
        );

        let participant = component.get('v.participant');
        component.set('v.needsGuardian', participant.Health_care_proxy_is_needed__c);
        if( component.get('v.needsGuardian') && participant.Adult__c && (participant.email__c ==''|| !participant.email__c) ){
            component.set('v.createUsers',false);
        }
        if(!participant.Health_care_proxy_is_needed__c){            
            component.set('v.delNotAdultErrMsg',false);
            component.set('v.yobBlankErrMsg',false);
        }

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

    approveDelegate: function (component, event, helper) {
        var ddi = component.get('v.delegateDuplicateInfo');
        var partDel = component.get('v.participantDelegate');
        if (ddi.contactPhoneType) partDel.Phone_Type__c = ddi.contactPhoneType;
        if (ddi.contactPhoneNumber) partDel.Phone__c = ddi.contactPhoneNumber;
        component.set('v.participantDelegate', partDel);
        component.find('delegate-phone').focus();
        component.find('delegate-phone').blur();
        component.set('v.useThisDelegate', true);
        component.set('v.isNewPrimaryDelegate',false);
        //helper.checkFields(component,event,helper, true);
    },

    doRefreshParticipant: function (component, event, helper) {
        var participant = component.get('v.participant');
        component.set('v.participant', participant);
    },

    doCreateUserInv: function (component) {
        component.set('v.createUsers', !component.get('v.createUsers'));
    },

    doContact: function (component) {
        if(!document.getElementById("checkbox-unique-id-76").checked){
            document.getElementById("cnLabel").classList.add("chErr");
            document.getElementById("cnLabelErr").classList.remove("slds-hide");
        }
        else{
            document.getElementById("cnLabel").classList.remove("chErr");
            document.getElementById("cnLabelErr").classList.add("slds-hide");
        }
        component.set('v.doContact', !component.get('v.doContact'));
        if (!component.get('v.doContact')) {
            component.set('v.createUsers', false);
        }
    },

    doContactEmail: function (component) {
        component.set('v.isEmail', !component.get('v.isEmail'));
    },

    doContactPhone: function (component) {
        component.set('v.isPhone', !component.get('v.isPhone'));
    },

    doContactSMS: function (component) {
        component.set('v.isSMS', !component.get('v.isSMS'));
    },

    handleConsentChange: function (component,event){
        if(event.getParam('consentMap').cType == 'study'){
            component.set('v.isEmail', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
            component.set('v.doContact', event.getParam('consentMap').pe.Permit_Mail_Email_contact_for_this_study__c);
            component.set('v.isPhone', event.getParam('consentMap').pe.Permit_Voice_Text_contact_for_this_study__c);
            component.set('v.isSMS', event.getParam('consentMap').pe.Permit_SMS_Text_for_this_study__c);
            component.set('v.createUsers', false);
        }else{
            component.set('v.contactConsent.Participant_Opt_In_Status_Emails__c',event.getParam('consentMap').contact.Participant_Opt_In_Status_Emails__c);
            component.set('v.contactConsent.Participant_Opt_In_Status_SMS__c',event.getParam('consentMap').contact.Participant_Opt_In_Status_SMS__c);
            component.set('v.contactConsent.Participant_Phone_Opt_In_Permit_Phone__c',event.getParam('consentMap').contact.Participant_Phone_Opt_In_Permit_Phone__c);
            component.set('v.contactConsent.IQVIA_Direct_Mail_Consent__c',event.getParam('consentMap').contact.IQVIA_Direct_Mail_Consent__c);
        }
    }
});