/**
 * Created by Igor Malyuta on 13.01.2020.
 */

({
    doInit: function (component, event, helper) {
        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        component.set('v.phonePattern', '[+]?[1-9][(][0-9]{3}[)][\\s]?[0-9]{3}[-][0-9]{4}');

        let sectionData = component.get('v.contactSectionData');
        component.set('v.countriesLVList', sectionData.countriesLVList);
        component.set('v.gendersLVList', sectionData.gendersLVList);
        component.set('v.statesByCountryMap', sectionData.statesByCountryMap);
        let personWrapper = component.get('v.personWrapper');

        component.set('v.statesLVList', sectionData.statesByCountryMap[personWrapper.mailingCC]);
    },

    doCountryCodeChanged: function (component, event, helper) {
        let statesByCountryMap = component.get('v.statesByCountryMap');
        let personWrapper = component.get('v.personWrapper');

        component.set('v.statesLVList', statesByCountryMap[personWrapper.mailingCC]);
        personWrapper.mailingSC = null;
        component.set('v.personWrapper', personWrapper);
    },

    doStateChanged: function (component, event, helper) {
    //     let snapShot = component.get('v.contactSnapshot');
    //     let currentState = JSON.stringify(component.get('v.contact'));
    //     component.set('v.contactChanged', snapShot !== currentState);
    },

    doCheckFieldsValidity: function(component, event, helper){
        helper.setFieldsValidity(component);
    }
});