/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {},
            function (links) {
            component.set('v.links', links);
            console.log('links' + JSON.stringify(links));
            component.find('spinner').hide();
        });
    }
});