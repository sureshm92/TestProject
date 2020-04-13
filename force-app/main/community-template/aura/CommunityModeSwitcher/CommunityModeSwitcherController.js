/**
 * Created by Leonid Bartenev
 */
({

    doSelectItem: function (component, event, helper) {
        const item = event.getSource();
        const selectedMode = item.get('v.itemValue');
        if(selectedMode.isGroup){
            selectedMode.isOpen = !selectedMode.isOpen;
            component.set('v.allModes', component.get('v.allModes'));
        }else if(!selectedMode.isSplitter){
            var currentDelegateId = selectedMode.currentDelegateId;
            if(selectedMode.userMode === 'HCP'){
                currentDelegateId = selectedMode.currentHCPDelegate;
            }
            communityService.executeAction(component, 'changeMode', {
                mode: selectedMode.userMode,
                delegateId: currentDelegateId,
                peId: selectedMode.currentPE
            }, function (contact) {
                component.set('v.currentMode', selectedMode);
                communityService.setCurrentCommunityMode(selectedMode);
                //do nothing if need redirect:
                if(selectedMode.template.needRedirect) return;
                if(communityService.getUserMode() === 'Participant'){
                    communityService.navigateToPage(communityService.getFullPageName());
                }else{
                    communityService.navigateToPage('');
                }
                if(communityService.showTourOnLogin() && !communityService.isTourAlreadyShowed()  && communityService.isNewSession()) {
                    communityService.showTour();
                }
                var modes = component.get('v.allModes');
                for(var i = 0; i < modes.length; i ++){
                    if(modes[i].isGroup) modes[i].isOpen = false;
                }

                communityService.executeAction(component, 'getMessagesVisibility', {}, function (returnValue) {
                    communityService.setMessagesVisible(returnValue);
                    component.set('v.allModes', modes);
                    component.getEvent('onModeChange').fire();
                    component.find('pubsub').fireEvent('reload');
                });
            });
        }
    }
});