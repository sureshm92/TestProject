({
    checkValidEmail: function (component, event, helper) {
        var email = event.getSource();
        var emailValue = email.get('v.value');
        var el = component.get('v.studyInformation');
        if (emailValue) {
            var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
            var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
            var invalidCheck = regexpInvalid.test(emailValue);
            if (invalidCheck == false) {
                email.setCustomValidity('');
                if (emailValue.match(regexp)) {
                    email.setCustomValidity('');
                    var el = component.get('v.studyInformation');
                    el.isStudySiteEmailValid = true;
                } else {
                    email.setCustomValidity('You have entered an invalid format');
                    var el = component.get('v.studyInformation');
                    el.isStudySiteEmailValid = false;
                }
            } else {
                email.setCustomValidity('You have entered an invalid format');
                el.isStudySiteEmailValid = false;
                //isValid = false;
            }
            email.reportValidity();
        } else {
            email.setCustomValidity('');
            el.isStudySiteEmailValid = true;
            email.reportValidity();
        }
        component.set('v.studyInformation', el);
    },
    
    doSiteInfoComplete:function (component) {
        component.set('v.siteInfoComplete', !component.get('v.siteInfoComplete'));
        var el = component.get('v.studyInformation');
        el.isRecordUpdated = true;
        el.siteInfoComplete = component.get('v.siteInfoComplete');
        component.set('v.studyInformation', el);
        if(el.isRecordUpdated == true){
            var p = component.get('v.parentComponent');
        }
        
    },
    
    doTrainingComplete:function(component){
        component.set('v.trainingComplete', !component.get('v.trainingComplete'));
        var el = component.get('v.studyInformation');
        el.isRecordUpdated = true;
        el.trainingComplete = component.get('v.trainingComplete');
        component.set('v.studyInformation', el);
        if(el.isRecordUpdated == true){
            var p = component.get('v.parentComponent');
        }
    },
    
    doSupressEmail:function(component){
        component.set('v.supressEmail', !component.get('v.supressEmail'));
        var el = component.get('v.studyInformation');
        el.isRecordUpdated = true;
        el.receivePIEmail = component.get('v.supressEmail');
        component.set('v.studyInformation', el);
        if(el.isRecordUpdated == true){
            var p = component.get('v.parentComponent');
        }
    },
    
    
    changeUpdatedStatus: function (component, event) {
        var el = component.get('v.studyInformation');
        if(el.siteName != ''){
            el.isRecordUpdated = true;
            component.set('v.isModifiedInfo',true);
        }
        else{
            el.isRecordUpdated = false;
            component.set('v.isModifiedInfo',false);
        }
        component.set('v.studyInformation', el);
        
    },
    
})