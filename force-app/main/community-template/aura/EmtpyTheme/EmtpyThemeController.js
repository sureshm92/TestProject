/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) {
            communityService.initialize(component);
            component.set('v.initialized', true);
        }
        if (communityService.isInitialized()) {
            component.set('v.communitySiteName', communityService.getCommunityName());
            component.set('v.communityName', communityService.getCurrentCommunityName());
            if (
                communityService.getCurrentCommunityName() == 'Janssen Community' ||
                communityService.getCurrentCommunityName() == 'IQVIA Patient Portal' ||
                communityService.getCurrentCommunityName() == 'IQVIA Referral Hub'
            ) {
                component.set('v.isDummy', communityService.isDummy());
            }
            console.log('is Dummy', communityService.isDummy());
        }
    }
});
