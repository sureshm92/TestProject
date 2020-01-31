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
                    component.set('v.isDelegateMode', communityService.getCurrentCommunityMode().currentDelegateId);
                    component.set('v.showTrialSearch',
                        !communityService.getCurrentCommunityMode().currentDelegateId &&
                        !ps.participant.Marketing_Flag__c &&
                        !ps.pe
                        );
                    component.find('spinner').hide();
                }
                component.set('v.initialized', true);
            });
    },

    navigateToTrialSearchPage : function (component, event, helper) {
        communityService.navigateToPage('trial-search');
    }
})