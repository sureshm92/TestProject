({
    doInit : function (component, event, helper) 
    {
        component.set('v.mapMarkers', [
        {
            location: {
                City: 'New York',
                Country : 'United state',
            },
            title: 'United state',
            description: 'New York'
        }
        ]);
        helper.waitAccountCheckResult(component, 0);
    },

    changeMapMarker : function(component, event, helper) 
    {  
        /*var index = event.getSource().get('v.name');
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;*/

        /*var rectarget = event.currentTarget;
        var index = rectarget.getAttribute("data-conId"); */

        var index = event.currentTarget.dataset.rowIndex;
        
        var siteAddress = component.get("v.distaceStudySites");
        component.set("v.studySitesInstance",siteAddress[index].studySite);
        component.set('v.mapMarkers', [
        	{
                location: {
                    City: siteAddress[index].studySite.Site__r.BillingCity,
                    Country: siteAddress[index].studySite.Site__r.BillingCountry,
                    PostalCode: siteAddress[index].studySite.Site__r.BillingPostalCode,
                    State: siteAddress[index].studySite.Site__r.BillingState,
                    Street: siteAddress[index].studySite.Site__r.BillingStreet
                }, 
                icon: 'custom:custom86',
                title: siteAddress[index].studySite.Name,
                description: siteAddress[index].studySite.Site__r.BillingStreet +siteAddress[index].studySite.Site__r.BillingState + ',' +siteAddress[index].studySite.Site__r.BillingCountry +','+siteAddress[index].studySite.Site__r.BillingPostalCode
            }
         ]);
        component.set('v.zoomLevel', 16);
         component.set('v.showFooter', true);	
         //component.set('v.markersTitle', siteAddress[index].Site__r.BillingStreet + ' '+siteAddress[index].Site__r.BillingCity + ' ' +siteAddress[index].Site__r.BillingCountry + ' ' +siteAddress[index].Site__r.BillingCity +' '+siteAddress[index].Site__r.BillingPostalCode);

    }
})