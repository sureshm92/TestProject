/**
 * Created by Igor Malyuta on 26.08.2019.
 */
({
    updateTable : function (component) {
        let data = component.get('v.data');
        let cCodes = component.get('v.countryCodes');
        if (!cCodes) component.set('v.countryFilterType', 'All');

        let langCodes = component.get('v.langCodes');
        if (!langCodes) component.set('v.langFilterType', 'All');

        let ssIds = component.get('v.selectedSSIds');
        if(!ssIds) component.set('v.sitesFilterType', 'All');

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            data: JSON.stringify(data),
            countryCodes: cCodes,
            langCodes: langCodes,
            ssId: ssIds,
        }, function (data) {
            component.set('v.data', data);
            component.set('v.ssItems', data.studySiteItems);

            component.set('v.allRecordsCount', data.paginationData.allRecordsCount);
            component.set('v.currentPage', data.paginationData.currentPage);
            component.set('v.languages', data.languages);

            component.find('spinner').hide();
        });
    }
});