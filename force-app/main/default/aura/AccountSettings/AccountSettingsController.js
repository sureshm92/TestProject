({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'getInitData', {
            userMode: component.get("v.userMode")
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            initData.password = {};
            initData.password.old = '';
            initData.password.new = '';
            initData.password.reNew = '';
            component.set("v.initData", initData);
            component.set("v.currentEmail", initData.myContact.Email);
            component.set('v.isInitialized', true);
        }, null, function () {
            component.set("v.showSpinner", false);
        })
    },

    doChangeEmail: function (component, event, helper) {
        var initData = component.get("v.initData");
        var newEmail = initData.myContact.Email;
        if(!newEmail) {
            communityService.showToast("error", "error", $A.get("$Label.c.TST_Email_can_t_be_empty"));
            return;
        }
        var oldEmail = component.get("v.currentEmail");
        if(newEmail === oldEmail) {
            communityService.showToast("waring", "warning", $A.get("$Label.c.TST_Emails_are_same"));
            return;
        }

        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'changeEmail', {
            newEmail: newEmail
        }, function (returnValue) {
            component.set("v.currentEmail", newEmail);
            communityService.showToast("success", "success", $A.get("$Label.c.TST_Your_email_address_has_been_updated"));
        }, null, function () {
            component.set("v.showSpinner", false);
        })
    },

    doChangePassword: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var initData = component.get("v.initData");

        communityService.executeAction(component, 'changePassword', {
            newPassword: initData.password.new,
            verifyNewPassword: initData.password.reNew,
            oldPassword: initData.password.old
        }, function (returnValue) {
            communityService.showToast("success", "success", $A.get("$Label.c.TST_Your_password_has_been_changed_successfully"));
            var initData = component.get("v.initData");
            initData.password.new = '';
            initData.password.reNew = '';
            initData.password.old = '';
            component.set("v.initData", initData);
        }, null, function () {
            component.set("v.showSpinner", false);
        });
    },

    doSwitchOptInEmail : function (component, event, helper) {
        var initData = component.get("v.initData");
        communityService.executeAction(component, 'changeOptInEmail', {
            participantOptInStatusEmail: initData.myContact.Participant_Opt_In_Status_Emails__c,
            hcpOptInPatientEmail: initData.myContact.HCP_Opt_In_Patient_Status_Emails__c,
            hcpOptInStudyEmail: initData.myContact.HCP_Opt_In_Study_Emails__c,
            hcpOptInRefStatusEmail: initData.myContact.HCP_Opt_In_Referral_Status_Emails__c
        }, function () {
            //do nothing
        });
    },

    doSubmitQuestion : function (component, event, helper) {
        var description = component.get("v.privacyFormText");
        if(!description) {
            communityService.showToast("warning", "warning", $A.get("$Label.c.TST_Complete_Your_Question"));
            return;
        }

        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'createCase', {
            description: description,
            type: 'Privacy'
        }, function () {
                communityService.showToast("success", "success",  $A.get("$Label.c.TST_Thank_you_for_submitting_your_question"));
                component.set("v.privacyFormText",'');
        },null,function () {
            component.set("v.showSpinner", false);
        })
    }
})