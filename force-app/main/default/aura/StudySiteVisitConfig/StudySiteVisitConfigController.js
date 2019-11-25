/**
 * Created by Igor Malyuta on 18.09.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (initData) {
            component.set('v.filter', initData.filter);
            component.set('v.viewModePage', initData.viewMode);
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

    doAddVP: function (component, event, helper) {
        component.find('actionVP').execute(null, function () {
            component.refresh();
        }, 'create');
    },

    whenCountryFilterChanged: function (component, event, helper) {
        let filterType = component.get('v.countryFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('countryLookup').focus();
                }), 100
            );
        }
    },

    whenVPFilterChanged: function (component, event, helper) {
        let filterType = component.get('v.vpFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('vpLookup').focus();
                }), 100
            );
        }
    },

    whenSSFilterChanged: function (component, event, helper) {
        let filterType = component.get('v.sitesFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('ssLookup').focus();
                }), 100
            );
        }
    },

    //Visit Plan column actions: ---------------------------------------------------------------------------------------
    columnCheckboxStateChange: function (component, event, helper) {
        let vpId = event.target.dataset.vp;
        let state = event.target.dataset.state === 'Enabled';
        component.find('spinner').show();
        communityService.executeAction(component, 'setVisitPlanForAll', {
            visitPlanId: vpId,
            state: state,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination')),
            ssItemsJSON: JSON.stringify(component.get('v.ssItems'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    },

    doColumnVisitEdit: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(menuCmp.get('v.plan').value, function () {
            component.refresh();
        }, 'edit');
    },

    doColumnVisitView: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(menuCmp.get('v.plan').value, function () {
            component.refresh();
        }, 'view');
    },

    doColumnVisitClone: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(menuCmp.get('v.plan').value, function () {
            component.refresh();
        }, 'clone');
    },

    doColumnVisitDelete: function (component, event, helper) {
        let menuCmp = event.getSource();
        let planId = menuCmp.get('v.plan').value;
        component.find('spinner').show();
        communityService.executeAction(component, 'deleteVisitPlan', {
            planId: planId,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    }
});