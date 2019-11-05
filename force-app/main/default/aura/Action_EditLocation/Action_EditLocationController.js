/**
 * Created by Nikita Abrazhevitch on 21-Aug-19.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (initData) {
            component.set('v.countriesLVList', initData.countriesLVList);
            component.set('v.statesByCountryMap', initData.statesByCountryMap);
        })
    },

    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        var statesByCountryMap = component.get('v.statesByCountryMap');
        var account;
        if (params.account) {
            account = JSON.parse(JSON.stringify(params.account));
            if (account.BillingCountryCode) {
                var states = statesByCountryMap[account.BillingCountryCode];
                component.set('v.statesLVList', states);
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
        component.find('editLocation').show();
    },

    doCancel: function (component, event, helper) {
        component.find('editLocation').cancel();
    },

    doCheckAddress: function (component, event, helper) {
        component.set('v.showAddressValidationSpinner', true);
        var currentAccount = component.get('v.account');
        communityService.executeAction(component, 'createTmpAccountForLocationCheck', {
            account: JSON.stringify(currentAccount)
        }, function (createdAccountId) {
            helper.waitAccountCheckResult(component, createdAccountId, 0);
        });
    },

    doCheckFields: function (component, event, helper) {
        var account = component.get('v.account');
        if(account.BillingStateCode) {
            var statesLVList = component.get('v.statesLVList');
            /*for (let i = 0; i < statesLVList.length; i++) {
                if (account.BillingStateCode == statesLVList[i].value) {
                    account.BillingState = statesLVList[i].label;
                    break;
                }
            }*/
        }
        component.set('v.account' , account);
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
        /*for (let i = 0; i < countriesLVList.length; i++) {
            if(countriesLVList[i].value == account.BillingCountryCode){
                account.BillingCountry = countriesLVList[i].label;
                break;
            }
        }*/
        var states = statesByCountryMap[account.BillingCountryCode];
        account.BillingStateCode = null;
        account.BillingState = null;
        component.set('v.account', account);
        helper.checkAccountModified(component);
        component.set('v.statesLVList', states);
    },

    doUpsertAccount: function (component, event, helper) {
        var account = component.get('v.account');
        component.find('spinner').show();
        console.log('account>>>', JSON.parse(JSON.stringify(account)));
        communityService.executeAction(component, 'upsertAccount', {
            accountJSON: JSON.stringify(account),
            ssId: component.get('v.ssId')
        }, function (returnedAccount) {
            component.find('editLocation').hide();
            component.get('v.callback')(returnedAccount);
        }, null, function () {
            component.find('spinner').hide();
        });
    },
});