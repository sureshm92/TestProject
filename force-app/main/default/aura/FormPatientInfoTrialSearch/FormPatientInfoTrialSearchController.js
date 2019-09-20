/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        var formData = component.get('v.formData');
        var states = formData.statesByCountryMap['US'];
        component.set('v.statesLVList', states);
    },

    doCheckFields: function (component, event, hepler) {
        var participant = component.get('v.participantInfo');
        var stateRequired = component.get('v.statesLVList')[0];
        let isValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Email__c &&
            component.get('v.sendFor') !== '' &&
            component.find('emailInput').get('v.validity').valid;
        console.log(isValid);
        if (isValid) {
            component.set('v.isValid', true);
        } else {
            component.set('v.isValid', false);
        }
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var participant = component.get('v.participantInfo');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.checkFields();
    },

    onClickDisclaimer: function (component, event, helper) {
        component.set('v.isDisclaimer', !component.get('v.isDisclaimer'));
    },

    changeFor: function (component, event, helper) {
        if (component.get('v.sendFor') === 'Me') {
            let copyParticipant = JSON.parse(JSON.stringify(component.get('v.participant')));
            component.set('v.participantInfo', copyParticipant);
        } else {
            component.set('v.participantInfo', {});
        }
    }
})