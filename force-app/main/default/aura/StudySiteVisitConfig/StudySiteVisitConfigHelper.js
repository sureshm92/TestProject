/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    init: function (component, data) {
        component.set('v.data', data);
        component.set('v.ssItems', data.studySiteItems);
        component.set('v.haveEmptyVPSS', data.haveEmptyVPSS);
        component.set('v.visitPlans', data.visitPlans);

        component.set('v.allRecordsCount', data.paginationData.allRecordsCount);
        component.set('v.pageRecordsCount', data.paginationData.pageRecordsCount);
        component.set('v.currentPage', data.paginationData.currentPage);

        component.set('v.initialized', true);
        component.find('spinner').hide();
    },

    updateTable : function (component) {
        var data = component.get('v.data');
        var cCodes = component.get('v.countryCodes');
        if (!cCodes) component.set('v.countryFilterType', 'All');

        var selectedVPIds = component.get('v.selectedVPIds');
        if (!selectedVPIds) component.set('v.vpFilterType', 'All');

        var ssIds = component.get('v.selectedSSIds');
        if(!ssIds) component.set('v.sitesFilterType', 'All');

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            data: JSON.stringify(data),
            countryCodes: cCodes,
            selectedVPIds: selectedVPIds,
            ssId: ssIds,
        }, function (data) {
            component.set('v.data', data);
            component.set('v.ssItems', data.studySiteItems);

            component.set('v.allRecordsCount', data.paginationData.allRecordsCount);
            component.set('v.currentPage', data.paginationData.currentPage);
            component.set('v.visitPlans', data.visitPlans);

            component.find('spinner').hide();
        });
    }
});