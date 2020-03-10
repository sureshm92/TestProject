({
    doInit: function(component, event, helper){
        var pEnroll = component.get("v.participantEnrollment");
        helper.setData(component, pEnroll);
    },

    excludeFromReferring: function(component, event, helper){
        var pEnroll = component.get("v.participantEnrollment");
        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'changeStatusToExcludeFromReferring', {
            participantEnrollmentId: pEnroll.Id
        }, function (retrunValue) {
            component.set("v.participantEnrollment", {});
            pEnroll.Participant_Status__c = retrunValue;
            helper.setData(component, pEnroll);
            var Name = pEnroll.Participant_Surname__c ? pEnroll.Participant_Name__c + ' ' + pEnroll.Participant_Surname__c: pEnroll.Name;
            communityService.showToast("success", "success", Name + " " + $A.get("$Label.c.TST_has_been_successfully_excluded"));
            component.set("v.participantEnrollment", pEnroll);
            component.set("v.showSpinner", false);
            var parentCmp = component.get("v.parent");
            parentCmp.refresh();
        });
    }, 

    referToThisTrial: function(component, event, helper){
        var pEnroll = component.get("v.participantEnrollment");
        var trialId = pEnroll.Study_Site__r.Clinical_Trial_Profile__c;
        if(!trialId) communityService.showErrorToast("Error", $A.get("$Label.c.TST_Incorrect_enrollment"));
        communityService.navigateToPage('referring?id=' + trialId + '&peid=' + pEnroll.Id);
    },
    undoExcludeFromReferring: function(component, event, helper){
        var pEnroll = component.get("v.participantEnrollment");
        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'undoChangeStatusToExcludeFromReferring', {
            participantEnrollmentId: pEnroll.Id
        }, function (retrunValue) {
            component.set("v.participantEnrollment", {});
            pEnroll.Participant_Status__c = retrunValue;
            helper.setData(component, pEnroll);
            //communityService.showToast("success", "success", pEnroll.Name + " " + $A.get("$Label.c.TST_has_been_successfully_excluded"));
            component.set("v.participantEnrollment", pEnroll);
            component.set("v.showSpinner", false);
            var parentCmp = component.get("v.parent");
            parentCmp.refresh();
        });
    },

})