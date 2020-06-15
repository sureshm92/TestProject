({
    setPersonSnapshot: function(component){
        let personWrapper = component.get('v.personWrapper');
        if(!personWrapper.mailingCC) personWrapper.mailingCC = '';
        if(!personWrapper.mailingSC) personWrapper.mailingSC = '';
        if(!personWrapper.mailingCountry) personWrapper.mailingCountry = '';
        if(!personWrapper.mailingStreet) personWrapper.mailingStreet = '';
        if(!personWrapper.mailingCity) personWrapper.mailingCity = '';
        if(!personWrapper.mailingState) personWrapper.mailingState = '';
        if(!personWrapper.zip) personWrapper.zip = '';
        
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
})