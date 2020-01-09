/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {},
            function (links) {
            component.set('v.links', links);
            console.log('links' + JSON.stringify(links));
            if(!component.get("v.isAlumni") || links.length > 0) component.find('spinner').hide();
        });
    }
});