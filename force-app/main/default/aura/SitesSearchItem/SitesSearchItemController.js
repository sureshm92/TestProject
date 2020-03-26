/**
 * Created by Kryvolap on 26.03.2019.
 */
({
    navigateToReferring : function (component, event, helper) {
        var studySiteWrapper = component.get('v.studySiteWrapper');
        var trialId = studySiteWrapper.site.Clinical_Trial_Profile__c;
        var hcpeId = event.target.dataset.hcpeId;
        communityService.navigateToPage('referring?id=' + trialId +(hcpeId?'&hcpeid='+hcpeId:''));
    },
    requestToRefer : function (component, event, helper) {
        var refreshSource = component.get('v.parentComponent');
        var studySiteWrapper = component.get('v.studySiteWrapper');
        if (!studySiteWrapper) {
            communityService.showErrorToast("Error", $A.get("$Label.c.TST_Something_went_wrong"));
            return;
        }
        component.get('v.parentComponent').find('requestToReferByHCPAction').execute(studySiteWrapper.site.Clinical_Trial_Profile__r, studySiteWrapper.site.Id, studySiteWrapper.hcpe?studySiteWrapper.hcpe.Id:null, refreshSource, communityService.getDelegateId());
    }
})