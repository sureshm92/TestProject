/**
 * Created by Igor Malyuta on 13.03.2019.
 */
({
    doInit : function (component, event, helper) {
        var markers = component.get('v.markers');
        var accounts = component.get('v.accounts');
        for(var i = 0; i < accounts.length; i++) {
            var clinicWrapper = accounts[i];

            //Url forming
            var descriptionLink;
            if(communityService.getUserMode() === 'PI') {
                var url = window.location.href;
                url = url.substring(0, url.lastIndexOf('/'));
                var clinical = url + '/clinic-profile?id=' + clinicWrapper.clinic.Id;

                descriptionLink = '<a href="' + clinical + '" target="_blank">Clinic profile</a>';
            }
            else
                descriptionLink = '';


            markers.push({
                location: {
                    // Location Information
                    City: clinicWrapper.clinic.BillingCity,
                    Country: clinicWrapper.clinic.BillingCountry,
                    PostalCode: clinicWrapper.clinic.BillingPostalCode,
                    State: clinicWrapper.clinic.BillingState,
                    Street: clinicWrapper.clinic.BillingStreet,
                },
                // Extra info for tile in sidebar & infoWindow
                icon: 'custom:custom86',
                title: clinicWrapper.name, // e.g. Account.Name
                description : descriptionLink
            });
        }

        component.set('v.markers', markers);
    }
})