/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        var userMode =  communityService.getUserMode();
        communityService.executeAction(component, 'getMotivationalMessage', {
            userMode: communityService.getUserMode()
        }, function (message) {
            if(message) communityService.showInfoToast('Info', message);
        })
    }

})