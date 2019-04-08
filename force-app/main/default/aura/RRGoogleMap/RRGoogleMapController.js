/**
 * Created by Igor Malyuta on 13.03.2019.
 */
({
    doInit: function (component, event, helper) {
        var markers = [];
        var hasAddress = false;
        var accounts = component.get('v.accounts');
        for (var i = 0; i < accounts.length; i++) {
            var clinicWrapper = accounts[i];
            if(!clinicWrapper.clinic.BillingCity || !clinicWrapper.clinic.BillingStreet) {
                continue;
            }

            hasAddress = true;

            //Url forming
            var descriptionLink;
            if (communityService.getUserMode() === 'PI') {
                var url = window.location.href;
                url = url.substring(0, url.lastIndexOf('/'));
                var clinical = url + '/clinic-profile?id=' + clinicWrapper.clinic.Id;

                descriptionLink = '<a href=' + clinical + ' target=_blank>Clinic profile</a>';
            } else
                descriptionLink = '';

            markers.push({
                location: {
                    Street: clinicWrapper.clinic.BillingStreet,
                    City: clinicWrapper.clinic.BillingCity,
                    PostalCode: clinicWrapper.clinic.BillingPostalCode,
                    State: clinicWrapper.clinic.BillingState,
                    Country: clinicWrapper.clinic.BillingCountry
                },
                icon: 'custom:custom86',
                title: clinicWrapper.name,
                description: descriptionLink
            });
        }

        component.set('v.hasAddress', hasAddress);
        component.set('v.markers', markers);
    }

})