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
        var numbers=/^[0-9]*$/;

        let isValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            numbers.test(participant.Phone__c) &&
            participant.Email__c &&
            component.get('v.sendFor') !== '' &&
            component.find('emailInput').get('v.validity').valid;
        console.log(isValid);
        if (isValid) {
            if (numbers.test(participant.Phone__c)  && participant.Phone__c) {
                phoneField.setCustomValidity(""); // reset custom error message
   
               }
                        phoneField.reportValidity();
            component.set('v.isValid', true);
        } else {
            if(participant.Phone__c){
                if (!numbers.test(participant.Phone__c)) {
                 phoneField.setCustomValidity("Phone number must be numeric and mandatory");
                 } else {
                     phoneField.setCustomValidity(""); // reset custom error message
                 }
             }
                 else if(!participant.Phone__c){
                                 phoneField.setCustomValidity("Phone number must be numeric and mandatory");
                 }
                     else{
                         phoneField.setCustomValidity(""); // reset custom error message
                     }
              phoneField.reportValidity();
     
            component.set('v.isValid', false);
        }
    },
    handleHomePhoneValidation:function(component,event) {
        var inputValue = event.getSource().get("v.value");
        var phoneField=component.find('pField2');
        var numbers=/^[0-9]*$/;
        if(inputValue===""){
            phoneField.setCustomValidity("");  
        }
       if ((!numbers.test(inputValue)  && inputValue!=="")) {
        phoneField.setCustomValidity("Phone number must be numeric");
        component.set('v.isValid', false);

        } else {
            phoneField.setCustomValidity(""); // reset custom error 
            component.set('v.isValid', true);

        }
        phoneField.reportValidity();
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
            let participant = {sobjectType:'Participant__c',
                First_Name__c:'',
                Last_Name__c:'',
                Date_of_Birth__c:'',
                Gender__c:'',
                Phone__c:'',
                Phone_Type__c:'',
                Email__c:'',
                Mailing_Country_Code__c:'',
                Mailing_State_Code__c:'',
                Mailing_Zip_Postal_Code__c:'',
            };
            component.set('v.participantInfo', participant);
        }
    }
})