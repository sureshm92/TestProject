({
    selectTab: function (component, event, helper) {
        communityService.logError(function () {
            communityService.scrollToTop();
            component.set('v.currentTab', component.get("v.tabId"));
            history.pushState(null, '', communityService.getCommunityURLPathPrefix() + '/study-workspace?id=' + component.get('v.studyId') + '&tab=' + component.get('v.tabId'));
            //communityService.navigateToPage('study-workspace?id=' + component.get('v.studyId') + '&tab=' + component.get('v.tabId'));
        });
    }
})