({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);

        component.set('v.phonePattern', '[+]?[1-9][(][0-9]{3}[)][\\s]?[0-9]{3}[-][0-9]{4}');
        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };

            component.set('v.initData', initData);
            component.set('v.participant', initData.participant);
            console.log('Participant:' + JSON.stringify(initData.participant));
            component.set('v.participantHasUpdateTasks', initData.participantHasUpdateTasks);

            component.set('v.contact', initData.myContact);
            console.log('Contact:' + JSON.stringify(initData.myContact));
            //TODO check here:
            component.set('v.currentEmail', initData.myContact.Email);
            component.set('v.isDelegate', initData.isDelegate);
            component.set('v.gendersLVList', initData.gendersLVList);
            component.set('v.statesByCountryMap', initData.statesByCountryMap);
            component.set('v.countriesLVList', initData.countriesLVList);

            if(initData.participant){
                component.set('v.statesLVList', initData.statesByCountryMap[initData.participant.Mailing_Country_Code__c]);
                helper.setParticipantSnapshot(component);
            }else{
                component.set('v.statesLVList', initData.statesByCountryMap[initData.myContact.MailingCountryCode]);
                helper.setContactSnapshot(component);
            }
            setTimeout($A.getCallback(function() {
                helper.setFieldsValidity(component);
                component.showHelpMessageIfInvalid();
            }), 1000);
            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doShowHelpMessageIfInvalid: function(component){
        var fieldsGroup = 'cField';
        if(component.get('v.participant')) fieldsGroup = 'pField';
        component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            try{
                inputCmp.showHelpMessageIfInvalid();
            }catch (e) {
                console.error(e);
            }
        }, true);
    } ,

    doUpdateParticipant: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'updateParticipant', {
            cont: JSON.stringify(component.get('v.contact')),
            participantJSON : JSON.stringify(component.get('v.participant'))
        }, function () {
            component.set('v.participantHasUpdateTasks', false);
            helper.setParticipantSnapshot(component);
            var retString = communityService.getUrlParameter('ret');
            if(retString) {
                var retPage = communityService.getRetPage(retString);
                communityService.navigateToPage(retPage);
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doUpdateContact: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'updateContact', {
            cont: JSON.stringify(component.get('v.contact'))
        }, function () {
            component.set('v.participantHasUpdateTasks', false);
            helper.setContactSnapshot(component);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCountryCodeChanged: function(component, event, helper){
        if(!component.get('v.isInitialized')) return;
        var statesByCountryMap = component.get('v.statesByCountryMap');

        if(component.get('v.participant')){
            var participant = component.get('v.participant');
            var states = statesByCountryMap[participant.Mailing_Country_Code__c];
            component.set('v.statesLVList', states);
            component.set('v.participant.Mailing_State_Code__c', null);
        }else{
            var contact = component.get('v.contact');
            var states = statesByCountryMap[contact.MailingCountryCode];
            component.set('v.statesLVList', states);
            component.set('v.contact.MailingStateCode', null);
        }
    },

    doParticipantChanged: function(component, event, hepler){
        if(!component.get('v.isInitialized')) return;
        var snapShot = component.get('v.participantSnapshot');
        var currentState = JSON.stringify(component.get('v.participant'));
        component.set('v.participantChanged', snapShot !== currentState);
    },

    doContactChanged: function(component, event, hepler){
        if(!component.get('v.isInitialized')) return;
        var snapShot = component.get('v.contactSnapshot');
        var currentState = JSON.stringify(component.get('v.contact'));
        component.set('v.contactChanged', snapShot !== currentState);
    },

    doCheckFieldsValidity: function(component, event, helper){
        helper.setFieldsValidity(component);
    },

    doChangeEmail: function (component, event, helper) {
        var initData = component.get('v.initData');
        var newEmail = initData.myContact.Email;
        if (!newEmail) {
            communityService.showToast('error', 'error', $A.get('$Label.c.TST_Email_can_t_be_empty'));
            return;
        }
        var oldEmail = component.get("v.currentEmail");
        if (newEmail === oldEmail) {
            communityService.showToast("waring", "warning", $A.get('$Label.c.TST_Emails_are_same'));
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
        var initData = component.get('v.initData');

        communityService.executeAction(component, 'changePassword', {
            newPassword: initData.password.new,
            verifyNewPassword: initData.password.reNew,
            oldPassword: initData.password.old
        }, function (returnValue) {
            communityService.showToast('success', 'success', $A.get('$Label.c.TST_Your_password_has_been_changed_successfully'));
            var initData = component.get('v.initData');
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
        var initData = component.get('v.initData');
        communityService.executeAction(component, 'changeOptInEmail', {
            participantOptInStatusEmail: initData.myContact.Participant_Opt_In_Status_Emails__c,
            hcpOptInPatientEmail: initData.myContact.HCP_Opt_In_Patient_Status_Emails__c,
            hcpOptInStudyEmail: initData.myContact.HCP_Opt_In_Study_Emails__c,
            hcpOptInRefStatusEmail: initData.myContact.HCP_Opt_In_Referral_Status_Emails__c
        }, function () {
            //do nothing
        });
    },

    doSwitchOptInSMS: function (component, event, helper) {
        helper.changeSMSOption(component);
    },

    doSwitchOptInCookies: function (component, event, helper) {
        var initData = component.get('v.initData');
        communityService.executeAction(component, 'changeOptInCookies', {
            rrCookieAllowed: initData.myContact.RRCookiesAllowedCookie__c,
            rrLanguageAllowed: initData.myContact.RRLanguageAllowedCookie__c
        }, function () {
            location.reload();
        });
    },

    doSubmitQuestion: function (component, event, helper) {
        var description = component.get('v.privacyFormText');
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
    
    checkUpdate : function (component, event, helper) {
        component.set('v.isUpdated', true);
    },

    handleOkClick: function (component, event, helper) {
        communityService.executeAction(component, 'changeOptInVisitResults', {
            contactId: component.get('v.initData.myContact.Id'),
            isOptIn: component.get('v.initData.myContact.Visit_Results_Opt_In__c')
        }, function (returnValue) {
            component.set("v.initData.myContact.Visit_Results_Opt_In__c", returnValue);
            component.set("v.showModal", false);
        });
    },

    handleCancelClick: function (component, event, helper) {
        component.set("v.initData.myContact.Visit_Results_Opt_In__c", false);
        component.set("v.showModal", false);

    },

    openVisitResultsOptInModal: function (component, event, helper) {
        if (component.get("v.initData.myContact.Visit_Results_Opt_In__c")) {
            component.set("v.showModal", true);
        } else {
            communityService.executeAction(component, 'changeOptInVisitResults', {
                     contactId: component.get('v.initData.myContact.Id'),
                     isOptIn: component.get('v.initData.myContact.Visit_Results_Opt_In__c')
                 }, function (returnValue) {
                component.set("v.initData.myContact.Visit_Results_Opt_In__c", returnValue);
            });
        }
    },
})