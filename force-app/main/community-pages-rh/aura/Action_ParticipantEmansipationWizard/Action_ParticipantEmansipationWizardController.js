/**
 * Created by Alexey Moseev.
 */

({

    doInit: function (component, event, helper) {
        helper.preparePathItems(component);
    },

    doExecute: function (component, event, helper) {
        try {
            component.find('spinner').show();
            component.set('v.initialized', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            component.set('v.pe', pe);
            component.set('v.rootComponent', params.rootComponent);
            if (params.callback) component.set('v.callback', params.callback);

            communityService.executeAction(component, 'getInitData', null, function (formData) {
                component.set('v.formData', formData);
                console.log('Countries:');
                console.log(formData.countriesLVLis);
                let states = formData.statesByCountryMap['US'];
                component.set('v.statesLVList', states);
                component.set('v.currentTab', '1');
                component.set('v.initialized', true);
                component.set('v.participant', pe.Participant__r);
                component.find('spinner').hide();
            });
            component.set('v.participantMsgWithName', $A.get("$Label.c.PG_Ref_L_Participant_require_invitation").replace('##participantName', pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c));

            component.find('dialog').show();
        } catch (e) {
            console.error(e);
        }
    },

    doCallback: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.get('v.callback')(pe);
    },

    doCancel: function (component, event, helper) {
        var comp = component.find('dialog');
        comp.hide();
    },

    doHandleRadioClick : function(component, event, hepler){
        component.set('v.selectedOption', event.getSource().get('v.value'));
    },

    doCheckFields: function (component, event, hepler) {
        var participant = component.get('v.participant');
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        var pe = component.get('v.pe');
        var stateRequired = component.get('v.statesLVList')[0];
        var stateCmp = component.find('stateField');
        var stateVaild = stateCmp && stateCmp.get('v.validity') && stateCmp.get('v.validity').valid;
        var isValid = false;
        var today = new Date();
        var dateToday = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+(today.getDate());

        isValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Nickname__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            participant.Mailing_Zip_Postal_Code__c !== '' &&
            component.find('emailInput').get('v.validity').valid &&
            stateVaild;

        component.set('v.isValid', isValid);
        return isValid;
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var countryMap =  component.get('v.formData.countriesLVList');
        var participant = component.get('v.participant');
        for (let i = 0; i <countryMap.length ; i++) {
            if(countryMap[i].value == participant.Mailing_Country_Code__c){
                component.set('v.participant.Mailing_Country__c', countryMap[i].label);
                break;
            }
        }
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.set('v.participant.Mailing_State__c', null);
        component.checkFields();
    },

    doStateChange: function(component, event, helper){
        var states = component.get('v.statesLVList');
        if (states){
            var participant = component.get('v.participant');
            for (let i = 0; i < states.length ; i++) {
                if(states[i].value == participant.Mailing_State_Code__c){
                    component.set('v.participant.Mailing_State__c', states[i].label);
                    break;
                }
            }
        }
        component.checkFields();
    },

    doRefreshView: function(component, event, helper){
        component.set('v.isRefreshView', true);
        component.set('v.isRefreshView', false);
    }

});
