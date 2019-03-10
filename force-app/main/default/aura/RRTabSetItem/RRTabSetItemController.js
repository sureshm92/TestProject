({
    selectTab: function (component, event, helper) {
        communityService.logError(function () {
            communityService.scrollToTop();
            component.set('v.currentTab', component.get("v.tabId"));
        });
    }
})