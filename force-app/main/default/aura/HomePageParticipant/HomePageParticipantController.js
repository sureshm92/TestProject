/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null,
            function (returnValue) {
                var ps = JSON.parse(returnValue);
                if (ps.showTerms) {
                    communityService.navigateToPage("trial-terms-and-conditions?id=" + ps.pe.Study_Site__r.Clinical_Trial_Profile__c
                        + "&ret=" + communityService.createRetString());
                } else {
                    component.set('v.participantState', ps);
                    component.find('spinner').hide();
                }
            });
    }
})