/**
 * Created by Igor Malyuta on 02.09.2019.
 */

({
    doInit : function (component, event, helper) {
        communityService.executeAction(component, 'checkLanguagePermissions', {
            peId : component.get('v.peId')
        }, function (response) {
            //show popup or toast
            component.set('v.displayText', response.message);
            component.set('v.isNewSession', response.isNewSession);
            var mode = response.mode;
            switch (mode) {
                case 'empty': communityService.navigateToPage('no-data-to-display');
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
        communityService.navigateToPage('settings?tab=account-settings');
    }
});