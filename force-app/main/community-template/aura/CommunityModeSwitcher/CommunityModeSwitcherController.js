/**
 * Created by Leonid Bartenev
 */
({

    doSelectItem: function (component, event, helper) {
        const item = event.getSource();
        const selectedMode = item.get('v.itemValue');
        communityService.executeAction(component, 'changeMode', {
            mode: selectedMode.userMode,
            delegateId: selectedMode.currentHCPDelegate,
            peId: selectedMode.currentPE
        }, function (contact) {
            debugger;
            component.set('v.currentMode', selectedMode);
            communityService.setCurrentCommunityMode(selectedMode);
            if(communityService.getUserMode() == 'Participant'){
                communityService.navigateToPage(communityService.getFullPageName());
            }else{
                communityService.navigateToPage('');
            }

            if(communityService.showTourOnLogin() && !communityService.isTourAlreadyShowed()  && communityService.isNewSession()) {
                communityService.showTour();
            }
        });
    }

})