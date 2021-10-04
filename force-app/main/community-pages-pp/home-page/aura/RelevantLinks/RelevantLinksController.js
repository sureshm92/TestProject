/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        if (communityService) {
            communityService.executeAction(component, 'getInitData', {}, function (initData) {
                component.set('v.isAvailable', initData.linksAvailable);
                component.set('v.linksWrappers', initData.linksWrappers);
            });
        }
    }
});
