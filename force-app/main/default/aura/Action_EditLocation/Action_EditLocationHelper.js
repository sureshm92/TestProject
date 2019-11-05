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
            }  else {
                var acc = component.get('v.account');
                var initAcc = component.get('v.accountInitial');
                acc.BillingGeocodeAccuracy = tmpAccount.BillingGeocodeAccuracy;
                acc.BillingLongitude = tmpAccount.BillingLongitude;
                acc.BillingLatitude = tmpAccount.BillingLatitude;
                acc.BillingState = tmpAccount.BillingState ? tmpAccount.BillingState : null;
                acc.BillingStateCode = tmpAccount.BillingStateCode ? tmpAccount.BillingStateCode : null;
                acc.BillingPostalCode = tmpAccount.BillingPostalCode ? tmpAccount.BillingPostalCode : null;
                if(tmpAccount.BillingGeocodeAccuracy == 'Address' || tmpAccount.BillingGeocodeAccuracy == 'NearAddress' ||
                    tmpAccount.BillingGeocodeAccuracy == 'Block' || tmpAccount.BillingGeocodeAccuracy == 'Street' || tmpAccount.BillingGeocodeAccuracy == 'ExtendedZip'){
                    initAcc.BillingGeocodeAccuracy = tmpAccount.BillingGeocodeAccuracy;
                    initAcc.BillingLongitude = tmpAccount.BillingLongitude;
                    initAcc.BillingLatitude = tmpAccount.BillingLatitude;
                    initAcc.BillingState = tmpAccount.BillingState ? tmpAccount.BillingState : null;
                    initAcc.BillingStateCode = tmpAccount.BillingStateCode ? tmpAccount.BillingStateCode : null;
                    initAcc.BillingPostalCode = tmpAccount.BillingPostalCode ? tmpAccount.BillingPostalCode : null;
                    initAcc.BillingCity = tmpAccount.BillingCity;
                    initAcc.BillingCountryCode = tmpAccount.BillingCountryCode;
                    initAcc.BillingStreet = tmpAccount.BillingStreet;
                    component.set('v.accountInitial', initAcc);
                }
                component.set('v.account', acc);
                component.set('v.isAccountAddress', true);
                component.set('v.showAddressValidationSpinner', false);
                helper.setCoordinates(component);
            }
        });
    },

    setCoordinates: function (component) {
        var account = component.get('v.account');
        var state = account.BillingStateCode != null ? account.BillingStateCode : '';
        var postalCode = account.BillingPostalCode != null ? account.BillingPostalCode : '';
        component.set('v.mapMarkers', [
            {
                location: {
                    Latitude: account.BillingLatitude,
                    Longitude: account.BillingLongitude
                },
                title: 'Location Address',
                description: account.BillingCountry + ' ' + account.BillingStreet + ' ' + account.BillingCity + ' ' +
                state + ' ' + postalCode
            }
        ]);
        if (account.BillingLatitude && account.BillingLongitude) {
            component.set('v.zoomLevel', 17);
        } else {
            component.set('v.zoomLevel', 0);
        }
    },

    checkAccountModified: function (component) {
        var currentAccount = component.get('v.account');
        var accountInitial = component.get('v.accountInitial');
        var infoWasChanged = false;
        var addressWasChanged = false;
        var fieldsToCheck = ['Name', 'Parking_Instructions__c', 'Driving_Directions__c', 'BillingStreet', 'BillingCity', 'BillingCountryCode', 'BillingStateCode', 'BillingPostalCode'];
        for (let i = 0; i < fieldsToCheck.length; i++) {
            if (currentAccount[fieldsToCheck[i]] != accountInitial[fieldsToCheck[i]]) {
                if(!(currentAccount[fieldsToCheck[i]] == '' && !accountInitial[fieldsToCheck[i]])) {
                    infoWasChanged = true;
                }
            }
            if (fieldsToCheck[i].includes('Billing') && currentAccount[fieldsToCheck[i]] != accountInitial[fieldsToCheck[i]] && !addressWasChanged) {
                if(!(currentAccount[fieldsToCheck[i]] == '' && !accountInitial[fieldsToCheck[i]])) {
                    currentAccount.BillingGeocodeAccuracy = null;
                    currentAccount.BillingLatitude = null;
                    currentAccount.BillingLongitude = null;
                    component.set('v.account', currentAccount);
                    addressWasChanged = true;
                }
            } else if (fieldsToCheck[i].includes('Billing') && currentAccount[fieldsToCheck[i]] == accountInitial[fieldsToCheck[i]] && !addressWasChanged) {
                if(!(currentAccount[fieldsToCheck[i]] == '' && !accountInitial[fieldsToCheck[i]])) {
                    currentAccount.BillingGeocodeAccuracy = accountInitial.BillingGeocodeAccuracy;
                    currentAccount.BillingLatitude = accountInitial.BillingLatitude;
                    currentAccount.BillingLongitude = accountInitial.BillingLongitude;
                    component.set('v.account', currentAccount);
                }
            }
        }
        component.set('v.isAccountModified', infoWasChanged);
    }
})