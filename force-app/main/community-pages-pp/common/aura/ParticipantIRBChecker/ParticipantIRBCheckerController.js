/**
 * Created by Igor Malyuta on 02.09.2019.
 */

({
    doInit : function (component, event, helper) {
        if(!component.get('v.peId')) return;
        communityService.executeAction(component, 'checkLanguagePermissions', {
            peId : component.get('v.peId')
        }, function (response) {
            //show popup or toast
            component.set('v.displayText', response.message);
            component.set('v.studyCodeName', response.studyCodeName);
            component.set('v.isNewSession', response.isNewSession);
            var mode = response.mode;
            switch (mode) {
                case 'empty': component.find('emptyPopup').show();
                    break;
                case 'alternative': helper.showToast(component);
                    break;
                case 'no-approved': component.find('popup').show();
                    break;
                default:{}
            }
        });
    },

    navigateToSettings : function (component, event, helper) {
        communityService.navigateToPage('account-settings?langloc');
    },

    doLogOut: function (component, event, helper) {
        communityService.logOut();
    }
});