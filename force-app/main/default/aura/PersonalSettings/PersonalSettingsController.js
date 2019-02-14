({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        var tabId = communityService.getUrlParameter("tab");
        if(tabId && (tabId === "my-team" || tabId === "account-settings")) {
            if(communityService.getUserMode() === "Participant"){
                component.set("v.currentTab", "account-settings");
            } else {
                component.set("v.currentTab", tabId);
            }
        }
        component.set('v.userMode', communityService.getUserMode());
        component.set("v.showSpinner", false);
    }
})