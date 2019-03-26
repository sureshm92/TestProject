/**
 * Created by Igor Malyuta on 13.03.2019.
 */
({
    doInit: function (component, event, helper) {
        var markers = [];
        var accounts = component.get('v.accounts');
        for (var i = 0; i < accounts.length; i++) {
            var clinicWrapper = accounts[i];
            if(!clinicWrapper.clinic.BillingCity)
                continue;

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
                    Country: clinicWrapper.clinic.BillingCountry,
                    Latitude: clinicWrapper.clinic.BillingLatitude,
                    Longitude: clinicWrapper.clinic.BillingLongitude
                },
                icon: 'custom:custom86',
                title: clinicWrapper.name,
                description: descriptionLink
            });
        }

        component.set('v.markers', markers);
    }
})