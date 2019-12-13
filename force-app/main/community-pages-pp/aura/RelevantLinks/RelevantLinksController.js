/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {},
            function (vendors) {
            component.set('v.vendors', vendors);
        });

        component.find('spinner').hide();
    }
});