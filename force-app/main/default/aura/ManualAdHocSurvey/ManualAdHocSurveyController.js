/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    doCheckFields: function (component, event, helper) {
        var isValid = component.get('v.wrapper.selectedSurvey').length > 0;

        component.set('v.isValid', isValid);
        component.get('v.parent').setValidity(isValid);
    }
});