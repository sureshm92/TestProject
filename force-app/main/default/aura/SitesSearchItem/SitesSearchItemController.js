/**
 * Created by Kryvolap on 26.03.2019.
 */
({
    navigateToReferring : function (component, event, helper) {
        var studySiteWrapper = component.get('v.studySiteWrapper');
        var trialId = studySiteWrapper.site.Clinical_Trial_Profile__c;
        communityService.navigateToPage("referring?id=" + trialId);
    },
    requestToRefer : function (component, event, helper) {
        debugger;
        var refreshSource = component.get('v.parentComponent');
        var studySiteWrapper = component.get('v.studySiteWrapper');
        if (!studySiteWrapper) {
            communityService.showErrorToast("Error", $A.get("$Label.c.TST_Something_went_wrong"));
            return;
        }
        component.get('v.parentComponent').find('requestToReferByHCPAction').execute(studySiteWrapper.site.Clinical_Trial_Profile__r, studySiteWrapper.site.Id, refreshSource);
    }
})