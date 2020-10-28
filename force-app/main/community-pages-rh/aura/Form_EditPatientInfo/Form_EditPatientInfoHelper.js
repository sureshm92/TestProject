({
	  checkValidEmail : function(email,emailValue) {
         debugger;
        var isValid = false;
        if(email && emailValue) {
        var regexp = $A.get("$Label.c.RH_Email_Validation_Pattern");
            if(emailValue.match(regexp)) {
                email.setCustomValidity('');
                isValid = true;
            }else {
                email.setCustomValidity('You have entered an invalid format'); 
                isValid = false;
            }
            email.reportValidity(); 
        }
                return isValid;
    },
})