({
    doInit: function (component, event, helper) {

              component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId){
            component.set('v.isDelegate', true);}
        else{
            component.set('v.isDelegate', false);

        }
        
        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            let initData = JSON.parse(returnValue);
            console.log('initData',initData);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };
           
            
           let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        	component.set('v.todayDate', todayDate);
            component.set('v.initData', initData);
            component.set('v.contactChanged', initData.contactChanged);
            component.set('v.personWrapper', initData.contactSectionData.personWrapper);
            component.set('v.contactSectionData', initData.contactSectionData);
            component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
            component.set('v.optInSMS', initData.contactSectionData.personWrapper.optInSMS);
            component.set('v.contact', initData.myContact);
            component.set('v.userEmail', initData.myContact.Email);
            component.set('v.delegateContact',initData.delegateContact);
             if(communityService.getCurrentCommunityMode().currentDelegateId){
               component.set('v.userId',communityService.getCurrentCommunityMode().currentDelegateId);
console.log('inside delegate-->'+communityService.getCurrentCommunityMode().currentDelegateId);
                
            }
            else{
                component.set('v.userId',initData.myContact.Id);
                console.log('inside participant-->'+initData.myContact.Id)
            }
            console.log('initData.myContact.Email',initData.myContact.Email);

if(component.get('v.personWrapper.mobilePhone')==''){
    component.set('v.disableToggle',true);
}
            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doChangeEmail: function (component, event, helper) {
        let initData = component.get('v.initData');
        let newEmail = initData.myContact.Email;
        if (!newEmail) {
            communityService.showToast('error', 'error', $A.get('$Label.c.TST_Email_can_t_be_empty'));
            return;
        }
        let oldEmail = component.get('v.currentEmail');
        if (newEmail === oldEmail) {
            communityService.showToast('waring', 'warning', $A.get('$Label.c.TST_Emails_are_same'));
            return;
        }

        component.set('v.showSpinner', true);
        communityService.executeAction(component, 'changeEmail', {
            newEmail: newEmail
        }, function (returnValue) {
            component.set('v.currentEmail', newEmail);
            communityService.showToast('success', 'success', $A.get('$Label.c.TST_Your_email_address_has_been_updated'));
        }, null, function () {
            component.set('v.showSpinner', false);
        })
    },

    doChangePassword: function (component, event, helper) {
        component.set('v.showSpinner', true);
        let initData = component.get('v.initData');

        communityService.executeAction(component, 'changePassword', {
            newPassword: initData.password.new,
            verifyNewPassword: initData.password.reNew,
            oldPassword: initData.password.old
        }, function (returnValue) {
            communityService.showToast('success', 'success', $A.get('$Label.c.TST_Your_password_has_been_changed_successfully'));
            let initData = component.get('v.initData');
            component.set('v.initData.password', {
                old: '',
                new: '',
                reNew: ''
            });
        }, null, function () {
            component.set('v.showSpinner', false);
        });
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

    doSwitchOptInSMS: function (component, event, helper) {
        let optInSMS = component.get('v.optInSMS');
        communityService.executeAction(component, 'changeOptInSMS', {
            participantOptInStatusSMS: optInSMS
        }, function () {
           let smsOptIn = optInSMS;
           let personWrapper = component.get('v.personWrapper');
           personWrapper.optInSMS = smsOptIn;
           component.set('v.personWrapper', personWrapper);
           component.set('v.reRender', false);
           component.set('v.reRender', true);
           let phone = personWrapper.homePhone;
   
           if(personWrapper.optInSMS && !personWrapper.mobilePhone) {
               helper.setFieldsValidity(component);
              component.set('v.disableToggle',true);
               setTimeout(function () {
                   communityService.showInfoToast('', $A.get('$Label.c.Toast_Enter_Mob_Num'));
               }, 800);
           }

        });
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

    checkUpdate: function (component, event, helper) {
        component.set('v.isUpdated', true);
    },

    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');
        component.set('v.optInEmail', personWrapper.optInEmail);
        component.set('v.optInSMS', personWrapper.optInSMS);
        component.set('v.personWrapper', personWrapper);
    },
    doCheckFieldsValidity: function(component, event, helper){
        event.preventDefault();

        let personWrapper = component.get('v.personWrapper');
        if(!personWrapper.firstName || !personWrapper.lastName || !personWrapper.dateBirth){
            component.set('v.disableSave',true);
 
        }else{
            component.set('v.disableSave',false);
 
        }
        if(personWrapper.mailingCC !== component.get('v.previousCC')) {
            let statesByCountryMap = component.get('v.statesByCountryMap');
            let states = statesByCountryMap[personWrapper.mailingCC];
            component.set('v.statesLVList', states);
            component.set('v.previousCC', personWrapper.mailingCC);
            personWrapper.mailingSC = null;
            component.set('v.personWrapper', personWrapper);

            component.set('v.reRender', false);
            component.set('v.reRender', true);
        }

        helper.setFieldsValidity(component);
    },

    doShowHelpMessageIfInvalid: function (component) {
        let fieldsGroup = 'pField';
        component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            try {
                inputCmp.showHelpMessageIfInvalid();
            } catch (e) {
                console.error(e);
            }
        }, true);
    }
    ,

    doScrollInto: function (component, event, helper) {
        let smsOptIn = event.getParam('arguments').smsOptIn;
        let personWrapper = component.get('v.personWrapper');
        let regex = RegExp(component.get('v.phonePattern'));
        personWrapper.optInSMS = smsOptIn;
        component.set('v.personWrapper', personWrapper);
        component.set('v.reRender', false);
        component.set('v.reRender', true);
        let phone = personWrapper.homePhone;
        component.set('v.isAllFieldsValid', regex.test(phone));
        if(personWrapper.optInSMS && !personWrapper.mobilePhone) {
            helper.setFieldsValidity(component);
            setTimeout(function () {
                communityService.showInfoToast('', $A.get('$Label.c.Toast_Enter_Mob_Num'));
            }, 800);
        }
    }
    ,
    doUpdatePerson: function (component, event, helper) {
        var per=component.get('v.personWrapper');
        console.log(JSON.stringify(per));
            component.find('spinner').show();
            communityService.executeAction(component, 'updatePerson', {
                wrapperJSON: JSON.stringify(component.get('v.personWrapper'))
            }, function () {
                component.set('v.participantHasUpdateTasks', false);
                helper.setPersonSnapshot(component);
                component.find('spinner').hide();
                communityService.showToast('success', 'success', $A.get('$Label.c.PP_Profile_Update_Success'));
    
            });
        let initData = component.get('v.initData');
        let isUserDelegate = component.get('v.isDelegate');
        if(!isUserDelegate){
            let newEmail = initData.myContact.Email;
            if (!newEmail) {
           communityService.showToast('error', 'error', $A.get('$Label.c.TST_Email_can_t_be_empty'));
           return;
       }
       let oldEmail = component.get('v.currentEmail');
       if (newEmail === oldEmail) {
           communityService.showToast('waring', 'warning', $A.get('$Label.c.TST_Emails_are_same'));
           return;
       }    
       }
        component.set('v.showSpinner', true);
        communityService.executeAction(component, 'changeEmail', {
            newEmail: newEmail
        }, function (returnValue) {
            component.set('v.currentEmail', newEmail);
        }, null, function () {
            component.set('v.showSpinner', false);
        })
    },
    handleMobileValidation : function(component,event) {
        var inputValue = event.getSource().get("v.value");
        var phoneField=component.find('pField1');
        console.log('phoneField-->'+phoneField);
        console.log('inputValue-->'+inputValue);
        var numbers=/^[0-9]*$/ ;
        if(inputValue===""){
            phoneField.setCustomValidity("");  
        }
       if ((!numbers.test(inputValue)  && inputValue!=="")) {
           component.set('v.disableToggle',true);
        phoneField.setCustomValidity("Phone number must be numeric");
        component.set('v.disableSave',true);
        } else {
            phoneField.setCustomValidity(""); // reset custom error message
            component.set('v.disableSave',false);
            component.set('v.disableToggle',false);
        }
        phoneField.reportValidity();
    },
    handleHomePhoneValidation:function(component,event) {
        var inputValue = event.getSource().get("v.value");
        var phoneField=component.find('pField2');
        console.log('phoneField-->'+phoneField);
        console.log('inputValue-->'+inputValue);
        var numbers=/^[0-9]*$/;
       if ((!numbers.test(inputValue)  || !inputValue)) {
           if(!inputValue){
               phoneField.setCustomValidity("Phone number is mandatory");
           }
           else{
                       phoneField.setCustomValidity("Phone number must be numeric");
           }
        component.set('v.disableSave',true);

        } else {
            phoneField.setCustomValidity(""); // reset custom error message
            component.set('v.disableSave',false);

        }
        phoneField.reportValidity();
    },
    
    doStateChanged: function (component, event, helper) {
        let snapShot = component.get('v.personSnapshot');
        let personWrapper = component.get('v.personWrapper');
        let currentState = JSON.stringify(personWrapper);
        let isStateChanged = snapShot !== currentState;
        component.set('v.isStateChanged', isStateChanged);

        if(isStateChanged && (personWrapper.mailingCC !== component.get('v.previousCC'))) {
            setTimeout(function () {
                component.getEvent('onEdit').fire();
            }, 50);
        }
    }
});