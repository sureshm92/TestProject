({
	doInit: function (component, event, helper) {
        component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId) component.set('v.isDelegate', true);

        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            let initData = JSON.parse(returnValue);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };

            component.set('v.initData', initData);
            component.set('v.contactChanged', initData.contactChanged);
            component.set('v.personWrapper', initData.contactSectionData.personWrapper);
            component.set('v.contactSectionData', initData.contactSectionData);
            component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
            component.set('v.optInSMS', initData.contactSectionData.personWrapper.optInSMS);
            component.set('v.isDisabled',true);
            component.set('v.contact', initData.myContact);
            component.set('v.currentEmail', initData.myContact.Email);

            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
    
    onChangeInput : function(component,event,helper) {
        component.set('v.isDisabled',true);
        //Get password
        var password = component.get("v.initData.password.new");
        var oldpassword = component.get("v.initData.password.old");
        var renewpassword = component.get("v.initData.password.reNew");
          
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
        component.set("v.caps",strengthValue.caps);
        component.set("v.small",strengthValue.small);
        component.set("v.numbers",strengthValue.numbers);
        component.set("v.length",strengthValue.length);
        component.set("v.special",strengthValue.special);
        
        var i=0;
        if(strengthValue.caps && strengthValue.small && strengthValue.numbers){
            i=1;
        }else if(strengthValue.caps && strengthValue.small && strengthValue.special){
            i=2;
        }else if(strengthValue.caps && strengthValue.numbers && strengthValue.special){
            i=3;
        }else if(strengthValue.small && strengthValue.numbers && strengthValue.special){
            i=4;
        }
        
       
        var getoldPass = oldpassword;
        var getNewPass = password;
        var getReNewPass = renewpassword;
        if ((getoldPass == null || getoldPass == undefined ||  getoldPass.length == 0)
            || (getNewPass == null || getNewPass == undefined ||  getNewPass.length == 0 )
            || (getReNewPass == null || getReNewPass == undefined ||  getReNewPass.length == 0)){
                component.set('v.isDisabled',true);

            }else if(strengthValue.length && (i>0 && i<=4)){
            component.set('v.isDisabled',false);
            }

    },

    togglePassword: function (component, event, helper) {
        
        var id = event.currentTarget.id;
        if(id=='1'){
            component.set("v.showPasswordInput1", false)
            component.set("v.showPassword1", !component.get("v.showPassword1"));
            if(component.get("v.iconColor1") === "#999999") {
                component.set("v.iconColor1", "#297dfd");
            } else {
                component.set("v.iconColor1", "#999999");
            }
            component.set("v.showPasswordInput1", true);
        }else if(id=='2'){
            component.set("v.showPasswordInput2", false)
            component.set("v.showPassword2", !component.get("v.showPassword2"));
            if(component.get("v.iconColor2") === "#999999") {
                component.set("v.iconColor2", "#297dfd");
            } else {
                component.set("v.iconColor2", "#999999");
            }
            component.set("v.showPasswordInput2", true);
        }else if(id=='3'){
            component.set("v.showPasswordInput3", false)
            component.set("v.showPassword3", !component.get("v.showPassword3"));
            if(component.get("v.iconColor3") === "#999999") {
                component.set("v.iconColor3", "#297dfd");
            } else {
                component.set("v.iconColor3", "#999999");
            }
            component.set("v.showPasswordInput3", true);
        }
        
    },
     doChangePassword: function (component, event, helper) {
        component.set('v.showSpinner', true);
        let initData = component.get('v.initData');

        communityService.executeAction(component, 'changePassword', {
            newPassword: initData.password.new,
            verifyNewPassword: initData.password.reNew,
            oldPassword: initData.password.old
        }, function (returnValue) {
            communityService.showToast('success', 'success', $A.get('$Label.c.TST_Your_password_has_been_changed_successfully'));
            let initData = component.get('v.initData');
            component.set('v.initData.password', {
                old: '',
                new: '',
                reNew: ''
            });
        }, null, function () {
            component.set('v.showSpinner', false);
        });
    },
})