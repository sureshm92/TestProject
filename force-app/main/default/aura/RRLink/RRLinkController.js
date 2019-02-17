/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.set('v.href', communityService.getCommunityURLPathPrefix() + '/' + component.get('v.page'));
    },

    onClick: function (component, event) {
        event.preventDefault();
        var page = component.get('v.page');
        if(page) communityService.navigateToPage(page);
    }

})