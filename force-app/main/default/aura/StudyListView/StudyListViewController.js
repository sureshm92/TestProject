({
    doInit: function (component, event, helper) {
        helper.init(component,event,helper);

    },

    doUpdateRecords: function (cmp, event, helper) {
        helper.searchForRecords(cmp, helper, false);
    },

    doUpdateRecordsWithFirstPage: function (cmp, event, helper) {
        helper.searchForRecords(cmp, helper, true);
    },

    showNoThanksDialog: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.find('noTanksModal').show();
    },

    switchToSearchResume: function (cmp, event, helper) {
        cmp.set("v.isSearchResume", true);
        cmp.set("v.searchResumeChanged", true);
        helper.searchForRecords(cmp, helper);
    },

    saveSSDetails: function (component, event, helper){
        var param = event.getParam('arguments');
        var currentSS = param.currentSS;
       communityService.executeAction(component, 'saveSSChanges', {studySiteInfo: JSON.stringify(currentSS)}, function (returnValue) {
            if(returnValue == 'SUCCESS'){
                helper.init(component,event,helper);
                communityService.showToast(returnValue, 'success', $A.get("$Label.c.SS_Success_Save_Message"));
            }
       });
    },

    saveSSAddress: function (component,event,helper) {
        var param = event.getParam('arguments');
        var newAddress = param.newAddress;
        communityService.executeAction(component, 'saveSSAddress', {newAddress: JSON.stringify(newAddress)}, function (returnValue) {
            if(returnValue == 'SUCCESS'){
                this.doInit(component,event,helper);
                communityService.showToast(returnValue, 'success', $A.get("$Label.c.SS_Success_Save_Message"));
            }
        });
    }

});