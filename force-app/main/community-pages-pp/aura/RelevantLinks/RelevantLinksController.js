/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {},
            function (initData) {
                component.set('v.isAvailable', initData.linksAvailable);
                component.set('v.links', initData.resources);
                component.set('v.initialized', true);
            }, null, function () {
                component.find('spinner').hide();
            });
    }
});