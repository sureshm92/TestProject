/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (initData) {
            debugger;
            component.set('v.filter', initData.filter);
            component.set('v.viewMode', initData.viewMode);
            helper.setSearchResponse(component, initData.searchResponse);
            component.set('v.initialized', true);
        });
    },

    doUpdate: function (component, event, helper) {
        helper.updateItems(component);
    },

    doSaveAndUpdate: function(component, event, helper){
        helper.updateItems(component, true);
    },

    onCountriesChange: function (component, event, helper) {
        component.set('v.filter.selectedSSIds', '');
        helper.updateItems(component);
    },

    doSort: function (component, event, helper) {
        let sortDirection = component.get('v.filter.sortDirection');
        component.set('v.filter.sortField', event.currentTarget.dataset.order);
        if(sortDirection === 'ASC'){
            component.set('v.filter.sortDirection', 'DESC');
        }else{
            component.set('v.filter.sortDirection', 'ASC');
        }
        helper.updateItems(component);
    },

    doAddTravelVendor: function (component, event, helper) {
        component.find('addTravelVendorAction').execute(function(newVendorId){
            let vendorIds = component.get('v.filter.pageFeatureIds');
            if(vendorIds) vendorIds += ';' + newVendorId;
            component.set('v.filter.pageFeatureIds', vendorIds);
            helper.updateItems(component);
        });
    },

    doSelectAllInColumn: function (component, event, helper) {
        let travelVendorId = event.target.dataset.tv;
        let state = event.target.dataset.state === 'Enabled';
        component.find('spinner').show();
        communityService.executeAction(component, 'selectAllInColumn', {
            travelVendorId: travelVendorId,
            state: state,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination')),
            ssItemsJSON: JSON.stringify(component.get('v.ssItems'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    },



})