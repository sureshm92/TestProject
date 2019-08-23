/**
 * Created by Nikita Abrazhevitch on 20-Aug-19.
 */

({
    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        var ssWrapper = JSON.parse(JSON.stringify(params.studySiteWrapper));
        component.set('v.studySite', ssWrapper.studySite);
        component.set('v.studySiteAccounts', ssWrapper.accounts);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        component.find('manageLocation').show();
    },

    changeRadioMarker: function (component, event, helper) {
        var radioBtns = component.find('radioBtn');
        for (let i = 0; i < radioBtns.length; i++) {
            radioBtns[i].set('v.checked', false);
        }
        event.getSource().set('v.checked', true);
        component.set('v.checkedAccount', event.getSource().get('v.value'));
        component.set('v.locationWasChanged', true);
    },

    changeStudySiteAddress: function (component, event, helper) {
        component.find('modalSpinner').show();
        var studySite = component.get('v.studySite');
        studySite.Site__r = component.get('v.checkedAccount');
        studySite.Site__c = component.get('v.checkedAccount').Id;
        communityService.executeAction(component, 'changeSSAccount', {ssId : studySite.Id, accountId : studySite.Site__c}, function () {
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
            component.set('v.locationWasChanged', false);
            component.find('modalSpinner').hide();
            component.find('manageLocation').hide();
            component.get('v.callback')(studySite);
        });
    },

    doCancel: function (component, event, helper) {
        component.find('manageLocation').cancel();
    },

    editAccountAddress: function (component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var accountsList = component.get('v.studySiteAccounts');
        var account = accountsList[index];
        var studySite = component.get('v.studySite');
        component.find('editLocation').execute(account, studySite.Id, studySite.Principal_Investigator__c, function (account) {
            accountsList[index] = account;
            component.set('v.studySiteAccounts', accountsList);
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
        });
    },
});