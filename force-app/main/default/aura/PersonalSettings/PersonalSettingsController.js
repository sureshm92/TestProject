({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        component.set('v.showSpinner', true);
        var mode = communityService.getUserMode();
        console.debug('DEBUG>> USER MODE IS '+ mode);
        debugger;
        var tabId = communityService.getUrlParameter('tab');
        if(tabId) {
            if(mode === 'HCP' || mode === 'PI') {
                component.set('v.validMode', true);
                if (tabId === 'my-team' || tabId === 'account-settings')
                    component.set('v.currentTab', tabId);
            }
            if(mode === 'Participant') {
                component.set('v.validMode', true);
                if (tabId === 'delegates' || tabId === 'account-settings')
                    component.set('v.currentTab', tabId);
            }
            if(mode === 'Delegate' && tabId === 'account-settings')
                component.set('v.currentTab', tabId);
        }
        component.set('v.userMode', mode);
        component.set('v.showSpinner', false);
    }
})