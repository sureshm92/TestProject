/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        var userMode =  communityService.getUserMode();
        debugger;
        communityService.executeAction(component, 'getMotivationalMessage', {
            userMode: userMode
        }, function (message) {
            debugger;
            if(message) communityService.showInfoToast('Info', message);
        })
    }

})