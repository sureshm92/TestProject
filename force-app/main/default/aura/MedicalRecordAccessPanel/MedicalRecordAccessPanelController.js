/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getInitData',
            {
                ctpId: component.get('v.recordId')
            },
            function (initData) {
                component.set('v.filter', initData.filter);
                console.log('filter ',initData.filter);
                component.set('v.viewMode', initData.viewMode);
                helper.setSearchResponse(component, initData.searchResponse);
                component.set('v.initialized', true);
            }
        );
    },

    doUpdate: function (component, event, helper) {
        helper.updateItems(component);
    },

    doSaveAndUpdate: function (component, event, helper) {
        helper.updateItems(component, true);
    },

    onCountriesChange: function (component, event, helper) {
        component.set('v.filter.selectedSSIds', '');
        helper.updateItems(component);
    },

    doSort: function (component, event, helper) {
        helper.updateItems(component);
    },

    doAddMedicalVendor: function (component, event, helper) {
        component.find('addMedicalVendorAction').execute(
            null,
            function (vpId) {
                let vpIds = component.get('v.filter.pageFeatureIds');
                if (vpIds) vpIds += ';' + vpId;
                component.set('v.filter.pageFeatureIds', vpIds);
                helper.updateItems(component);
            },
             'create'
        );
    },

    doSelectAllInColumn: function (component, event, helper) {
        let travelVendorId = event.target.dataset.tv;
        let state = event.target.dataset.state === 'Enabled';
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'selectAllInColumn',
            {
                travelVendorId: travelVendorId,
                state: state,
                filterJSON: JSON.stringify(component.get('v.filter')),
                paginationJSON: JSON.stringify(component.get('v.pagination')),
                ssItemsJSON: JSON.stringify(component.get('v.ssItems'))
            },
            function (searchResponse) {
                helper.setSearchResponse(component, searchResponse);
            }
        );
    },
    doColumnVisitEdit: function (component, event, helper) {
         component.find('addMedicalVendorAction').execute(
            event.getSource().get('v.plan').value,
            function (vpId) {
                let vpIds = component.get('v.filter.pageFeatureIds');
                if (vpIds) vpIds += ';' + vpId;
                component.set('v.filter.pageFeatureIds', vpIds);
                helper.updateItems(component);
            },
             'edit'
        );
    },
});