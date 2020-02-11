/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(component.get('v.page')){
            component.set('v.href', communityService.getCommunityURLPathPrefix() + '/' + component.get('v.page'));
        }
    },

    onClick: function (component, event) {
        if(component.get('v.page')){
            event.preventDefault();
            var page = component.get('v.page');
            if(page !== undefined) communityService.navigateToPage(page);
        }
    }

})