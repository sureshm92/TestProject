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
        if(component.get('v.identifier')){
            if (!component.get('v.page')){
                component.set('v.page', ' ');
            }

            let onclickEvent = component.getEvent('onclick');
            onclickEvent.setParams({
                "message": component.get('v.page'),
                "identifier": component.get('v.identifier')
            });
            onclickEvent.fire();
        }

        if(component.get('v.page')){
            event.preventDefault();
            var page = component.get('v.page');
            if(page !== undefined) communityService.navigateToPage(page);
        }
    }
});