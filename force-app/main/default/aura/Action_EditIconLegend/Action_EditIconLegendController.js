/**
 * Created by Igor Malyuta on 24.09.2019.
 */

({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.planId', params.planId);
        component.find('modal').show();
    },

    cancelClick: function (component, event, helper) {
        component.find('modal').hide();
    },

    saveClick: function (component, event, helper) {
        component.find('legend').save(function () {
            component.find('modal').hide();
        });
    }
});