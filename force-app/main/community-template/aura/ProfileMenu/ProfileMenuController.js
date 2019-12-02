/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getUser', null, function (returnValue) {
            const userData = JSON.parse(returnValue);
            component.set('v.user', userData.user);
            component.set('v.participantName', userData.participantName);
            component.set('v.isDelegate', userData.isDelegate);
        })
    },

    doSelectItem: function (component, event, helper) {
        const item = event.getSource();
        const itemValue = item.get('v.itemValue');
        if(itemValue === 'logout'){
            helper.logout(component);
        }else{
            communityService.navigateToPage(itemValue);
        }
    }

})