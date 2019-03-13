/**
 * Created by Igor Malyuta on 13.03.2019.
 */
({
    doInit : function (component, event, helper) {
        var markers = component.get('v.markers');
        var accounts = component.get('v.accounts');
        for(var i = 0; i < accounts.length; i++) {
            var clinicWrapper = accounts[i];

            var url = window.location.href;
            let indexOf = url.lastIndexOf('/');
            url = url.substring(0, indexOf);
            var clinical = url + '/clinic-profile?id=' + clinicWrapper.clinic.Id;

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
                description : '<a href="' + clinical + '" target="_blank">'+ clinicWrapper.name + '</a>'
            });
        }

        component.set('v.markers', markers);
    }
})