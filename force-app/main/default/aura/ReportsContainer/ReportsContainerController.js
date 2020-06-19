/**
 * Created by Igor Malyuta on 09.04.2020.
 */

({
    doInit: function (component, helper, event) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            component.set('v.initialized', true);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});