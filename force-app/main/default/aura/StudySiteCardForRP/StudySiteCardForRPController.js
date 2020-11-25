/**
 * Created by Nikita Abrazhevitch on 26-Aug-19.
 */

({
    doReferPatient: function (cmp, event, helper) {
        var siteWrapper = cmp.get('v.siteWrapper');
        var trialId = siteWrapper.site.Clinical_Trial_Profile__c;
        var hcpeId = event.target.dataset.hcpeId;
        var siteId = event.target.dataset.siteId;

        communityService.navigateToPage(
            'referring?id=' +
                trialId +
                (hcpeId ? '&hcpeid=' + hcpeId : '') +
                (siteId ? '&siteid=' + siteId : '')
        );
    },

    doMyPatients: function (cmp, event, helper) {
        var siteWrapper = cmp.get('v.siteWrapper');
        var trialId = siteWrapper.site.Clinical_Trial_Profile__c;
        var siteId = event.target.dataset.siteId;
        communityService.navigateToPage(
            'my-patients?id=' + trialId + (siteId ? '&siteId=' + siteId : '')
        );
    }
});
