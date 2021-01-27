({
    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.account', params.account);

        var statesByCountryMap = component.get('v.statesByCountryMap');
        var account;
        if (params.account) {
            account = JSON.parse(JSON.stringify(params.account));
            if (account.BillingCountryCode) {
                var states = statesByCountryMap[account.BillingCountryCode];
                component.set('v.statesLVList', states);
            }
            if (account.BillingState) {
                account.BillingState = null;
            }
        } else {
            account = {
                sobjectType: 'Account',
                BillingCountryCode: null
            };
        }
        component.set('v.account', account);

        component.set('v.ssId', params.ssId);

        component.set('v.accountInitial', JSON.parse(JSON.stringify(account)));
        helper.checkAccountModified(component);
        helper.setCoordinates(component);
        //reset content:
        component.set('v.showContent', false);
        component.set('v.showContent', true);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
    },

    doCancel: function (component, event, helper) {
        component.set('v.editLocation', false);
        var p = component.get('v.parent');
        p.closeTab();
    },

    doCheckAddress: function (component, event, helper) {
        component.set('v.showAddressValidationSpinner', true);
        var currentAccount = component.get('v.account');
        communityService.executeAction(
            component,
            'createTmpAccountForLocationCheck',
            {
                account: JSON.stringify(currentAccount)
            },
            function (createdAccountId) {
                helper.waitAccountCheckResult(component, createdAccountId, 0);
            }
        );
    },

    doCheckFields: function (component, event, helper) {
        var account = component.get('v.account');
        if (account.BillingStateCode) {
            var statesLVList = component.get('v.statesLVList');
        }
        component.set('v.account', account);
        helper.checkAccountModified(component);
    },

    doTrimChanges: function (component, event, helper) {
        var val = event.getSource().get('v.value');
        event.getSource().set('v.value', val.trim());
        if (!event.getSource().checkValidity()) {
            event.getSource().showHelpMessageIfInvalid();
        }
    },

    doCountryChange: function (component, event, helper) {
        var statesByCountryMap = component.get('v.statesByCountryMap');
        var countriesLVList = component.get('v.countriesLVList');
        var account = component.get('v.account');
        var states = statesByCountryMap[account.BillingCountryCode];
        account.BillingStateCode = null;
        account.BillingCountry = null;
        account.BillingState = null;
        component.set('v.account', account);
        helper.checkAccountModified(component);
        component.set('v.statesLVList', states);
    },

    doUpsertAccount: function (component, event, helper) {
        var account = component.get('v.account');
        //component.find('spinner').show();
        communityService.executeAction(
            component,
            'upsertAccount',
            {
                accountJSON: JSON.stringify(account),
                ssId: component.get('v.ssId')
            },
            function (returnedAccount) {
                component.get('v.callback')(returnedAccount);
            },
            null,
            function () {
                //component.find('spinner').hide();
            }
        );
        //  var p = component.get('v.parent');
        //p.refreshTable();
        //   component.set('v.editLocation',false);
        //alert(component.get('v.accIndex'));
        // var p = component.get('v.parent');
        //  p.closeTab();
    }
});
