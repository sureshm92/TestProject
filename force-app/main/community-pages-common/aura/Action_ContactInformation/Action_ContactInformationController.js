/**
 * Created by Igor Malyuta on 13.01.2020.
 */

({
    doInit: function (component, event, helper) {
        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        component.set('v.phonePattern', '[+]?[1][(][0-9]{3}[)][\\s]?[0-9]{3}[-]?[0-9]{4}');

        let sectionData = component.get('v.contactSectionData');
        component.set('v.countriesLVList', sectionData.countriesLVList);
        component.set('v.gendersLVList', sectionData.gendersLVList);
        component.set('v.statesByCountryMap', sectionData.statesByCountryMap);
        let personWrapper = component.get('v.personWrapper');
        helper.setPersonSnapshot(component);
        component.set('v.previousCC', personWrapper.mailingCC);

        component.set('v.statesLVList', sectionData.statesByCountryMap[personWrapper.mailingCC]);

        setTimeout($A.getCallback(function () {
            helper.setFieldsValidity(component);
            component.showHelpMessageIfInvalid();
        }), 1000);
    },

    doUpdatePerson: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'updatePerson', {
            wrapperJSON: JSON.stringify(component.get('v.personWrapper'))
        }, function () {
            component.set('v.participantHasUpdateTasks', false);
            helper.setPersonSnapshot(component);
            component.find('spinner').hide();
        });
    },

    doStateChanged: function (component, event, helper) {
        let snapShot = component.get('v.personSnapshot');
        let personWrapper = component.get('v.personWrapper');
        let currentState = JSON.stringify(personWrapper);
        let isStateChanged = snapShot !== currentState;
        component.set('v.isStateChanged', isStateChanged);

        if(isStateChanged && (personWrapper.mailingCC !== component.get('v.previousCC'))) {
            setTimeout(function () {
                component.getEvent('onEdit').fire();
            }, 50);
        }
    },

    doScrollInto: function (component, event, helper) {
        let smsOptIn = event.getParam('arguments').smsOptIn;
        let personWrapper = component.get('v.personWrapper');
        let regex = RegExp(component.get('v.phonePattern'));
        personWrapper.optInSMS = smsOptIn;
        component.set('v.personWrapper', personWrapper);
        component.set('v.reRender', false);
        component.set('v.reRender', true);
        let phone = personWrapper.homePhone;
        component.set('v.isAllFieldsValid', regex.test(phone));

        if(personWrapper.optInSMS && !personWrapper.mobilePhone) {
            communityService.showInfoToast('', $A.get('$Label.c.Toast_Enter_Mob_Num'));
            component.find('mobileAnchor').scrollInto();
            helper.setFieldsValidity(component);
        }
    },

    doCheckFieldsValidity: function(component, event, helper){
        let personWrapper = component.get('v.personWrapper');
        if(personWrapper.mailingCC !== component.get('v.previousCC')) {
            let statesByCountryMap = component.get('v.statesByCountryMap');
            let states = statesByCountryMap[personWrapper.mailingCC];
            component.set('v.statesLVList', states);
            component.set('v.previousCC', personWrapper.mailingCC);
            personWrapper.mailingSC = null;
            component.set('v.personWrapper', personWrapper);

            component.set('v.reRender', false);
            component.set('v.reRender', true);
        }

        helper.setFieldsValidity(component);
    },

    doShowHelpMessageIfInvalid: function (component) {
        let fieldsGroup = 'pField';
        component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            try {
                inputCmp.showHelpMessageIfInvalid();
            } catch (e) {
                console.error(e);
            }
        }, true);
    }
});