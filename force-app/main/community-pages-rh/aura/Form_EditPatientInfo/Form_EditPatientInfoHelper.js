({
    checkValidEmail: function (email, emailValue) {
        debugger;
        var isValid = false;
        if (email && emailValue) {
            var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
            var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
            var invalidCheck = regexpInvalid.test(emailValue);
            if (invalidCheck == false) {
                email.setCustomValidity('');
                if (emailValue.match(regexp)) {
                    email.setCustomValidity('');
                    isValid = true;
                } else {
                    email.setCustomValidity('You have entered an invalid format');
                    isValid = false;
                }
            } else {
                email.setCustomValidity('You have entered an invalid format');
                isValid = false;
            }
            email.reportValidity();
        }

        return isValid;
    }
});
