({
    togglePassword: function (component, event, helper) {
        component.set("v.showPasswordInput", false);
        component.set("v.showPassword", !component.get("v.showPassword"));
        if(component.get("v.passwordIconColor") === "#999999") {
            component.set("v.passwordIconColor", "#297dfd");
        } else {
            component.set("v.passwordIconColor", "#999999");
        }
        component.set("v.showPasswordInput", true);
    },
    checkField: function (component, event, helper) {
        component.set('v.isSaveBtnDisable',false);
        if(component.get('v.valueString').length >= 200){
            communityService.showInfoToast('', $A.get('{!$Label.c.Message_Studies_Length}'));
        }
    },
    
    changePswd: function (component, event, helper) {
        //Get password
        var password = component.get("v.valueString");
          
        //Password Strength Check
        let strengthValue = {
            'caps': false,
            'length': false,
            'special': false,
            'numbers': false,
            'small': false
        };
          
        //Check Password Length
        if(password.length >= 8) {
            strengthValue.length = true;
        }
         
        //Calculate Password Strength
        for(let index=0; index < password.length; index++) {
            let char = password.charCodeAt(index);
            if(!strengthValue.caps && char >= 65 && char <= 90) {
                strengthValue.caps = true;
            } else if(!strengthValue.numbers && char >=48 && char <= 57){
                strengthValue.numbers = true;
            } else if(!strengthValue.small && char >=97 && char <= 122){
                strengthValue.small = true;
            } else if(!strengthValue.special && (char >=33 && char <= 47) || (char >=58 && char <= 64) || (char >=91 && char <=96) || (char >=123 && char <=126)) {
                strengthValue.special = true;
            }
        }
          
        //component.set("v.passwordStrength", strength[strengthIndicator]);
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "caps" : strengthValue.caps,
            "small" : strengthValue.small,
            "numbers" : strengthValue.numbers,
            "length" : strengthValue.length,
            "special" : strengthValue.special
        });
        cmpEvent.fire();
    }
})
