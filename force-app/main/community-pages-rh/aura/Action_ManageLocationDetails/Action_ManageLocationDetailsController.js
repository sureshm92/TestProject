/**
 * Created by Nikita Abrazhevitch on 20-Aug-19.
 */

({
    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        var ssWrapper = JSON.parse(JSON.stringify(params.studySiteWrapper));
        component.set('v.studySite', ssWrapper.studySite);
        helper.sortAndSetAccountsByName(component, ssWrapper.accounts);
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
        var accountsList = JSON.parse(JSON.stringify(component.get('v.studySiteAccounts')));
        var studySite = component.get('v.studySite');
        var account = accountsList[index];
        if (!account) {
            account = {
                BillingCountryCode: studySite.Principal_Investigator__r.Account.BillingCountryCode,
                BillingStateCode: studySite.Principal_Investigator__r.Account.BillingStateCode,
                sobjectType: 'Account'
            }
        }
        component.find('editLocation').execute(account, studySite.Id, function (account) {
            if(index){
                accountsList[index] = account;
            } else{
                accountsList.push(account);
            }
            helper.sortAndSetAccountsByName(component, accountsList);
            studySite.Site__c = account.Id;
            studySite.Site__r = account;
            //component.set('v.studySiteAccounts', accountsList);
            //component.set('v.studySite', studySite);
            var radioBtns = component.find('radioBtn');
            for (let i = 0; i < radioBtns.length; i++) {
                if(radioBtns[i].get('v.value').Id == account.Id){
                    radioBtns[i].set('v.checked', true);
                } else {
                    radioBtns[i].set('v.checked', false);
                }
            }
            communityService.showToast('success', 'success', $A.get('$Label.c.SS_Success_Save_Message'));
            component.get('v.callback')(studySite, accountsList);
            //component.set('v.refresh', true);
            //component.set('v.refresh', false);
            //component.find('manageLocation').hide();
            //component.find('manageLocation').show();

        });
    },
});