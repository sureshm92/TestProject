/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        let userMode =  communityService.getUserMode();
        communityService.executeAction(component, 'getMotivationalMessage', {
            userMode: communityService.getUserMode()
        }, function (message) {
            if(message) communityService.showInfoToast('Info', message);
        });
    }

});