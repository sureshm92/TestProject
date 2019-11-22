/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    init: function (component, data) {
        component.set('v.data', data);
        component.set('v.ssItems', data.studySiteItems);
        component.set('v.haveEmptyVPSS', data.haveEmptyVPSS);
        component.set('v.visitPlans', data.visitPlans);

        component.set('v.allRecordsCount', data.searchWrapper.pagination.allRecordsCount);
        component.set('v.pageRecordsCount', data.searchWrapper.pagination.pageRecordsCount);
        component.set('v.currentPage', data.searchWrapper.pagination.currentPage);

        component.set('v.initialized', true);
        component.find('spinner').hide();
    },

    updateTable : function (component, helper) {
        let data = component.get('v.data');
        if (!data.searchWrapper.countryCodes) component.set('v.countryFilterType', 'All');
        if (!data.searchWrapper.pageFeatureIds) component.set('v.vpFilterType', 'All');
        if(!data.searchWrapper.selectedSSIds) component.set('v.sitesFilterType', 'All');

        helper.updateSorting(component);

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            data: JSON.stringify(data)
        }, function (data) {
            component.set('v.data', data);
            component.set('v.ssItems', data.studySiteItems);

            component.set('v.allRecordsCount', data.searchWrapper.pagination.allRecordsCount);
            component.set('v.currentPage', data.searchWrapper.pagination.pageRecordsCount);
            component.set('v.visitPlans', data.visitPlans);

            component.find('spinner').hide();
        });
    },

    updateSorting: function (component, isAction) {
        let data = component.get('v.data');
        let sortOrder = component.get('v.sortOrder');
        data.searchWrapper.filter.sortField = sortOrder;

        if(isAction) {
            let sortDirection;
            if (sortOrder === 'country') {
                sortDirection = !component.get('v.countrySortType');
                component.set('v.countrySortType', sortDirection);
            } else if (sortOrder === 'name') {
                sortDirection = !component.get('v.nameSortType');
                component.set('v.nameSortType', sortDirection);
            } else if (sortOrder === 'number') {
                sortDirection = !component.get('v.numberSortType');
                component.set('v.numberSortType', sortDirection);
            }
            data.searchWrapper.filter.sortDirection = sortDirection ? 'ASC' : 'DESC';
        }

        component.set('v.data', data);
    }
});