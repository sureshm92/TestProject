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

            var mode = response.mode;
            switch (mode) {
                case 'empty': communityService.navigateToPage('no-data-to-display');
                    break;
                case 'alternative': $A.enqueueAction(component.get('c.doShowToast'));
                    break;
                case 'no-approved': component.find('popup').show();
                    break;
                default:{}
            }
        });
    },

    doShowToast : function (component, event, helper) {
        console.log(communityService.isNewSession());

        if(!communityService.isNewSession() && helper.isToastDisplayed(component.get('v.peId'))) return;

        var template = component.get('v.displayText') + ' {0}';
        var accUrl = 'settings?tab=account-settings';
        var urlLabel = $A.get('$Label.c.PP_IRB_Button_Review');

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'warning',
            mode: 'sticky',
            message: 'This is a required message',
            messageTemplate: template,
            messageTemplateData: [{
                url: accUrl,
                label: urlLabel
            }]
        });
        toastEvent.fire();
    },

    navigateToSettings : function (component, event, helper) {
        communityService.navigateToPage('settings?tab=account-settings');
    }
});