/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var page = component.get('v.page');
        if(!component.get('v.href') || page){
            if(!page) page = '';
            component.set('v.href', communityService.getCommunityURLPathPrefix() + '/' + page);
        }
    },

    onClick: function (component, event) {
        component.doInit();
        if(component.get('v.page')){
            event.preventDefault();
            var page = component.get('v.page');
            if(page !== undefined) communityService.navigateToPage(page);
        }
    }
});