/**
 * Created by Kryvolap on 13.08.2019.
 */
({
    clearInviteFields: function (component, event, helper) {
        component.set("v.firstName", '');
        component.set("v.lastName", '');
        //component.set("v.clinicName", '');
        component.set("v.phone", '');
        component.set("v.emailS", '');
        component.set("v.studySiteId", '');
        component.set("v.hcpContactId", '');
        component.set("v.isDuplicate", false);
        var studySitesForInvitation = component.get('v.studySitesForInvitation');
        for(var i = 0; i< studySitesForInvitation.length; i++){
            studySitesForInvitation[i].selected = false;
        }
        component.set("v.studySitesForInvitation", studySitesForInvitation);
    },
    checkFields : function (component, event, helper) {
        var firstName = component.get('v.firstName');
        var lastName = component.get('v.lastName');
        //var clinicName = component.get('v.clinicName');
        var phone = component.get('v.phone');
        var emailS = component.get('v.emailS');
        var inputPattern = new RegExp('[!+@#$%^&*(),.?":{}|<>]','g');
        var phonePattern = new RegExp('[!@#$%^&*,.?":{}|<>]','g');
        var isPhoneValid = !phonePattern.test(phone);
        var reqFieldsFilled;
        if((((communityService.isValidEmail(emailS) && (phone == '' || phone == undefined)) ||
            (isPhoneValid && phone.trim() && (emailS == '' || emailS == undefined)) ||
            (communityService.isValidEmail(emailS) && (phone.trim() && isPhoneValid))) &&
            (!inputPattern.test(lastName) && lastName.trim()) &&
            (!inputPattern.test(firstName) && firstName.trim()))){
            reqFieldsFilled = true;
        }
        /*var reqFieldsFilled = (((communityService.isValidEmail(emailS) && (phone == '' || phone == undefined)) ||
            (isPhoneValid && phone.trim() && (emailS == '' || emailS == undefined)) ||
            (communityService.isValidEmail(emailS) && (phone.trim() && isPhoneValid))) &&
            (!inputPattern.test(lastName) && lastName.trim()) &&
            (!inputPattern.test(firstName) && firstName.trim()));*/
        var delegatePIs = component.get('v.PIForInvetation');
        if(delegatePIs.length > 0){
            console.log('delegatePIs>>',delegatePIs);
            var chosenPis = component.get('v.checkboxGroupValues');
            if(chosenPis.length < 1){
                reqFieldsFilled = false;
            }
        }
        component.set('v.reqFieldsFilled', reqFieldsFilled);
}})