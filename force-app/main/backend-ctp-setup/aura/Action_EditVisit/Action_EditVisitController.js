/**
 * Created by Igor Malyuta on 24.09.2019.
 */

({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        let visit = params.visit;
        if (!visit) {
            visit = {
                sobjectType: 'Visit__c',
                Icons__c: ''
            };
            component.set('v.mode', 'new');
        } else {
            component.set('v.mode', 'edit');
        }

        component.set('v.visit', visit);
        component.set('v.oldVisit',  JSON.stringify(visit) );
        component.set('v.callback', params.callback);
        component.set('v.cancelCallback', params.cancelCallback);
        component.find('iconsSet').reset();
        let modal = component.find('modal');
        modal.set('v.cancelCallback', params.cancelCallback);
        modal.show();
        component.validateInputs();
        
    },

    checkValidity: function (component, event, helper) {
        let visit = component.get('v.visit');
        let isValid =
            !visit.Name || !visit.Icons__c || !visit.Visit_Number__c || visit.Visit_Number__c < 1;
        if(component.get('v.communitytemplate') == 'PatientPortal'){
        let motivMsgValidity = component.find("motivationalMsg").get("v.validity");
        let descripMsgValidity = component.find("descriptionMsg").get("v.validity");
        isValid = isValid || (!motivMsgValidity.valid) || (!descripMsgValidity.valid);
        component.set('v.showMotivHelpTxt',component.find("motivationalMsg").reportValidity());
        component.set('v.showDesriptionHelpTxt',component.find("descriptionMsg").reportValidity());
        }
        
        component.set('v.isValid', isValid);
    },

    saveVisit: function (component, event, helper) {
        let callback = component.get('v.callback');
        if (callback) callback(component.get('v.visit'));
        component.find('modal').hide();
    },

    cancelClick: function (component, event, helper) {
        let visitOld =JSON.parse(component.get('v.oldVisit'));
        component.set('v.visit.Visit_Description__c',visitOld.Visit_Description__c);
        component.set('v.visit.Motivational_Message__c',visitOld.Motivational_Message__c);
        component.find('modal').cancel();
    }
});
