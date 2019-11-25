/**
 * Created by Igor Malyuta on 26.08.2019.
 */
({
    updateTable: function (component, helper) {
        let filter = component.get('v.filter');
        if (!filter.countryCodes) component.set('v.countryFilterType', 'All');
        if (!filter.pageFeatureIds) component.set('v.langFilterType', 'All');
        if (!filter.selectedSSIds) component.set('v.sitesFilterType', 'All');

        helper.updateSorting(component);

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            wrapper: JSON.stringify(component.get('v.pageWrapper')),
            filter: JSON.stringify(filter)
        }, function (response) {
            component.set('v.pageWrapper', response);
            component.set('v.ssItems', response.studySiteItems);

            component.set('v.allRecordsCount', response.pagination.allRecordsCount);
            component.set('v.currentPage', response.pagination.currentPage);
            component.set('v.languages', response.pageColumnItems);

            component.find('spinner').hide();
        });
    },
    
    updateSorting: function (component, isAction) {
        let filter = component.get('v.filter');
        let sortOrder = component.get('v.sortOrder');
        filter.sortField = sortOrder;

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
            filter.sortDirection = sortDirection ? 'ASC' : 'DESC';
        }

        component.set('v.filter', filter);
    }
});