/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    doCheckFields: function (component, event, helper) {
        let isValid = true;
        let selectedSurvey = component.get('v.wrapper.selectedSurvey');
        if(!selectedSurvey || selectedSurvey.length <= 0) isValid = false;

        isValid = isValid && component.find('daysToExpire').get('v.validity').valid;

        component.set('v.isValid', isValid);
        component.get('v.parent').setValidity(isValid);
    }
});