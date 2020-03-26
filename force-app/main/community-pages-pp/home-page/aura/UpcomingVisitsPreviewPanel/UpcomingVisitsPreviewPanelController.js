/**
 * Created by Igor Malyuta on 08.04.2019.
 */
({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getVisitsPreview', null, function(response) {
            component.set('v.visitWrappers', response);
            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    closeModal : function (component, event, helper) {
        component.find('showVendors').hide();
    },
})