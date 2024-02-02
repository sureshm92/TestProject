/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            component.set('v.communityService', communityService);
            if (communityService.getCurrentCommunityMode().hasPastStudies) {
                component.set(
                    'v.showPastStudies',
                    communityService.getCurrentCommunityMode().hasPastStudies
                );
            }
            communityService.executeAction(component, 'getInitData', null, function (returnValue) {
                var ps = JSON.parse(returnValue);
                component.set('v.participantState', ps);
    
                component.set(
                    'v.isDelegateMode',
                    communityService.getCurrentCommunityMode().currentDelegateId
                );
    
                if (
                    ps.communityName === 'IQVIA Referral Hub' ||
                    ps.communityName === 'IQVIA Patient Portal'
                )
                    component.set(
                        'v.showTrialSearch',
                        !communityService.getCurrentCommunityMode().currentDelegateId &&
                            !ps.participant.Marketing_Flag__c &&
                            !ps.pe
                    );
    
                component.find('spinner').hide();
                component.set('v.initialized', true);
            });    
        }
        else {
            communityService.initialize(component);
        }
    },

    navigateToTrialSearchPage: function (component, event, helper) {
        communityService.navigateToPage('trial-search');
    }
});
