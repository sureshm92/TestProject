/**
 * Created by user on 21-Aug-19.
 */

({
    doInit: function(component, event, helper){
        communityService.executeAction(component, 'getInitData', null, function (initData) {
            component.set('v.countriesLVList', initData.countriesLVList);
            component.set('v.statesByCountryMap', initData.statesByCountryMap);
        })
    },

    doExecute: function(component, event, helper){
        var params = event.getParam('arguments');
        var statesMapByCountry = component.get('v.statesByCountryMap');
        var account;
        if(params.account){
            account = JSON.parse(JSON.stringify(params.account));
            if(account.BillingCountryCode){
                var states = statesByCountryMap[account.BillingCountryCode];
                component.set('v.statesLVList', states);
            }
        }else{
            account = {
                sobjectType: 'Account',
                BillingCountryCode: null
            };
        }
        component.set('v.account', account);
        component.set('v.ssId', params.ssId);
        component.set('v.accountStamp', JSON.stringify(account));
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
        component.set('v.showPopUpSpinner', true);
        var currentAccount = component.get('v.account');
        communityService.executeAction(component, 'createTmpAccountForLocationCheck', {
            account: JSON.stringify(currentAccount)
        }, function (createdAccountId) {
            debugger;
            helper.waitAccountCheckResult(component, createdAccountId, 0);
        });
    },

    doCheckFields: function (component, event, helper) {
        helper.checkAccountModified(component);
    },

    doTrimChanges: function (component, event, helper) {
        var val = event.getSource().get('v.value');
        event.getSource().set('v.value', val.trim());
        if(!event.getSource().checkValidity()){
            event.getSource().showHelpMessageIfInvalid();
        }
    },

    doCountryChange: function (component, event, helper) {
        var statesByCountryMap = component.get('v.statesByCountryMap');
        var account = component.get('v.account');
        var states = statesByCountryMap[account.BillingCountryCode];
        component.set('v.statesLVList', states);
        component.set('v.account.BillingStateCode', null);
    },

    doUpsertAccount: function (component, event, helper) {
        var account = component.get('v.account');
        component.find('spinner').show();
        communityService.executeAction(component, 'upsertAccount', {
            accountJSON: JSON.stringify(account),
            ssId: component.get('v.ssId')
        }, function () {
            component.get('v.callback')(account);
        });
    },




});