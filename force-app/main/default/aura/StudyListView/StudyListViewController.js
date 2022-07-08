({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            helper.init(component, event, helper);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doUpdateRecords: function (cmp, event, helper) {
        if (communityService.getUserMode() === 'HCP') {
            helper.searchForRecords(cmp, helper, false);
        } else if (communityService.getUserMode() === 'PI') {
            helper.updateRecordsPI(cmp, helper);
        }
    },

    doUpdateRecordsWithFirstPage: function (cmp, event, helper) {
        if (communityService.getUserMode() === 'HCP') {
            helper.searchForRecords(cmp, helper, true);
        } else if (communityService.getUserMode() === 'PI') {
            helper.updateRecordsPI(cmp, helper);
        }
    },

    showNoThanksDialog: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.set('v.currentSSId', params.ssId);
        component.find('noTanksModal').show();
    },

    switchToSearchResume: function (cmp, event, helper) {
        cmp.set('v.isSearchResume', true);
        cmp.set('v.searchResumeChanged', true);
        helper.searchForRecords(cmp, helper);
    },

    clampTitle: function (component, event, helper) {
        setTimeout(
            $A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
            }),
            10
        );
    }

    /*saveSSDetails: function (component, event, helper) {
        var param = event.getParam('arguments');
        var currentSS = param.currentSS;
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'saveSSChanges', {studySiteInfo: JSON.stringify(currentSS)}, function (returnValue) {
            communityService.showToast('success', 'success', $A.get("$Label.c.SS_Success_Save_Message"));
            helper.init(component, event, helper);
        });
    },

    saveSSnewAddress: function (component, event, helper) {
        var param = event.getParam('arguments');
        var currentSS = param.currentSS;
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        communityService.executeAction(component, 'saveSSAddress', {studySiteInfo: JSON.stringify(currentSS)}, function (returnValue) {
            communityService.showToast('success', 'success', $A.get("$Label.c.SS_Success_Save_Message"));
            helper.init(component, event, helper);
        });
    }*/
});