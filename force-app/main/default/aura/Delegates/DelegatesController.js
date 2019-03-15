/**
 * Created by Igor Malyuta on 15.03.2019.
 */
({

    delegateClick: function (component, event, helper) {
        communityService.navigateToPage('delegates');
    },

    settingsClick: function (component, event, helper) {
        communityService.navigateToPage('settings?tab=account-settings');
    }
})