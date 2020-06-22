({
    setPersonSnapshot: function(component){
        let personWrapper = component.get('v.personWrapper');
        if(!personWrapper.firstName) personWrapper.firstName = '';
        if(!personWrapper.middleName) personWrapper.middleName = '';
        if(!personWrapper.lastName) personWrapper.lastName = '';
        if(!personWrapper.dateBirth) personWrapper.dateBirth = '';
        if(!personWrapper.gender) personWrapper.gender = '';
        if(!personWrapper.homePhone) personWrapper.homePhone = '';
        if(!personWrapper.mobilePhone) personWrapper.mobilePhone = '';
        if(!personWrapper.fax) personWrapper.fax = '';
        if(!personWrapper.mailingCC) personWrapper.mailingCC = '';
        if(!personWrapper.mailingSC) personWrapper.mailingSC = '';
        if(!personWrapper.mailingCountry) personWrapper.mailingCountry = '';
        if(!personWrapper.mailingStreet) personWrapper.mailingStreet = '';
        if(!personWrapper.mailingCity) personWrapper.mailingCity = '';
        if(!personWrapper.mailingState) personWrapper.mailingState = '';
        if(!personWrapper.zip) personWrapper.zip = '';
        if(!personWrapper.suffix) personWrapper.suffix = '';
        if(!personWrapper.nickname) personWrapper.nickname = '';
        if(!personWrapper.phoneType) personWrapper.phoneType = '';
        if(!personWrapper.prefix) personWrapper.prefix = '';

        
        
        component.set('v.personSnapshot', JSON.stringify(personWrapper));
        component.set('v.isStateChanged', false);
    },
    
     
    splitAddress : function (component, address) {
        var addLst = address.split('\n');
        var add1 = '';
        var add2 = '';
        if(addLst) {
            var s = addLst.length;
            debugger;
            if(s>0) {
                for(var i in addLst) {
                    
                    if(parseInt(i) <= 1) 
                        add1 = add1 + addLst[i];
                    else
                        add2 = add2 + addLst[i]; 
                }
                component.set('v.addressLine1', add1);
                component.set('v.addressLine2', add2);
            } else
                component.set('v.addressLine1', initData.contactSectionData.personWrapper.mailingStreet);
            
        } else
            component.set('v.addressLine1', initData.contactSectionData.personWrapper.mailingStreet);
        
        
        
    },

    setFieldsValidity: function(component){
        event.preventDefault();
        let fieldsGroup = 'pField';
        let allValid = component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log('allValid--->'+allValid);
        component.set('v.isAllFieldsValid', allValid);
    },
})