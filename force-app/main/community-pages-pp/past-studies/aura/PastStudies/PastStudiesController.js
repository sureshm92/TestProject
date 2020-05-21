({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        communityService.executeAction(component, 'getPastStudyRecords', null, function (pastStudies) {
            component.set('v.pastStudiesList', pastStudies);
            component.set('v.isDelegateMode', communityService.getCurrentCommunityMode().currentDelegateId);
            component.set('v.initialized', true);
            component.find('spinner').hide();
            if(!communityService.getCurrentCommunityMode().hasPastStudies) communityService.navigateToHome();
        });
    }

});