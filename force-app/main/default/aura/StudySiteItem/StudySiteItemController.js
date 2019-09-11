/**
 * Created by Igor Malyuta on 04.09.2019.
 */

({
    viewStudySite: function (component, event, helper) {
        var ssId = event.currentTarget.dataset.ssid;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Study_Site__c',
                recordId: ssId
            },
        };

        component.get('v.parent').find('navLink').navigate(pageRef);
    },

    sscCheckboxStateChange: function (component, event, helper) {
        var lang = event.getParam('field');
        var state = event.getParam('value');

        var item = component.get('v.item');
        var appLangs = item.approvedLangCodes;
        var appCount = 0;
        for (var j = 0; j < appLangs.length; j++) {
            if (appLangs[j].value === lang) appLangs[j].state = state;
            if (appLangs[j].state) appCount++;
        }
        item.emptyAppLangs = appCount === 0;
        component.set('v.item', item);
    }
});