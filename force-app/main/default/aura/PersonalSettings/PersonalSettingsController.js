({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        component.set('v.showSpinner', true);
        var tabId = communityService.getUrlParameter('tab');
        if(tabId) {
            if(communityService.getUserMode() === 'HCP' || communityService.getUserMode() === 'PI') {
                if (tabId === 'my-team' || tabId === 'account-settings')
                    component.set('v.currentTab', tabId);
            }
            else if(communityService.getUserMode() === 'Participant')
                if(tabId === 'delegates' || tabId === 'account-settings')
                    component.set('v.currentTab', tabId);
        }
        component.set('v.userMode', communityService.getUserMode());
        component.set('v.showSpinner', false);
    }
})