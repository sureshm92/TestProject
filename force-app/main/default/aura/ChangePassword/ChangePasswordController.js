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

            component.set('v.contact', initData.myContact);
            component.set('v.currentEmail', initData.myContact.Email);

            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
    togglePassword: function (component, event, helper) {
        component.set("v.showPasswordInput", false);
        component.set("v.showPassword", !component.get("v.showPassword"));
        if(component.get("v.iconColor") === "#999999") {
            component.set("v.iconColor", "#297dfd");
        } else {
            component.set("v.iconColor", "#999999");
        }
        component.set("v.showPasswordInput", true);
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