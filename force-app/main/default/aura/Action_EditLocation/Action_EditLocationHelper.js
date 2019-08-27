/**
 * Created by Leonid Bartenev
 */
({
    waitAccountCheckResult: function (component, tmpAccountId, iteration) {
        if (iteration === 15) {
            var acc = component.get('v.account');
            acc.BillingGeocodeAccuracy = null;
            acc.BillingLongitude = null;
            acc.BillingLatitude = null;
            component.set('v.account', acc);
            component.set('v.showAddressValidationSpinner', false);
            helper.setCoordinates(component);
            communityService.executeAction(component, 'deleteTmpAccount', {
                tmpAccountId: tmpAccountId
            });
            return;
        }
        var helper = this;
        communityService.executeAction(component, 'getTmpAccount', {
            tmpAccountId: tmpAccountId
        }, function (tmpAccount) {
            if (!tmpAccount.BillingGeocodeAccuracy) {
                window.setTimeout(
                    $A.getCallback(function () {
                        helper.waitAccountCheckResult(component, tmpAccountId, iteration + 1);
                    }), 500
                );
            } else {
                var acc = component.get('v.account');
                acc.BillingGeocodeAccuracy = tmpAccount.BillingGeocodeAccuracy;
                acc.BillingLongitude = tmpAccount.BillingLongitude;
                acc.BillingLatitude = tmpAccount.BillingLatitude;
                component.set('v.account', acc);
                component.set('v.showAddressValidationSpinner', false);
                helper.setCoordinates(component);
            }
        });
    },

    setCoordinates: function (component) {
        var account = component.get('v.account');
        component.set('v.mapMarkers', [
            {
                location: {
                    Latitude: account.BillingLatitude,
                    Longitude: account.BillingLongitude
                },
                title: 'Location Address',
                description: account.BillingCountry + ' ' + account.BillingStreet + ' ' + account.BillingCity + ' ' +
                    account.BillingStateCode + ' ' + account.BillingPostalCode
            }
        ]);
        if (account.BillingLatitude && account.BillingLongitude) {
            component.set('v.zoomLevel', 17);
        } else {
            component.set('v.zoomLevel', 0);
        }
    },

    checkAccountModified: function (component) {
        var account = component.get('v.account');
        var newAccountStamp = JSON.parse(JSON.stringify(account));
        var accountStamp = component.get('v.accountStamp');
        for(var key in newAccountStamp){
            if(newAccountStamp[key] == ''){
                delete newAccountStamp[key];
            }
        }
        newAccountStamp = JSON.stringify(newAccountStamp);
        component.set('v.isAccountModified', newAccountStamp !== accountStamp);
    }
})