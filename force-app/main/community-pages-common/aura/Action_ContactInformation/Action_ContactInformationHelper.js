/**
 * Created by Igor Malyuta on 13.01.2020.
 */

({
    setPersonSnapshot: function(component){
        let personWrapper = component.get('v.personWrapper');
        if(!personWrapper.FirstName) personWrapper.FirstName = '';
        if(!personWrapper.LastName) personWrapper.LastName = '';
        if(!personWrapper.MailingCC) personWrapper.MailingCC = '';
        if(!personWrapper.MailingSC) personWrapper.MailingSC = '';
        if(!personWrapper.Phone) personWrapper.Phone = '';
        if(!personWrapper.MobilePhone) personWrapper.MobilePhone = '';
        component.set('v.personSnapshot', JSON.stringify(personWrapper));
        component.set('v.isStateChanged', false);
    },

    setFieldsValidity: function(component){
        let fieldsGroup = 'pField';
        let allValid = component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        component.set('v.isAllFieldsValid', allValid);
    },
});