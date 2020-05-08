/**
 * Created by Alexey Moseev on 5/7/20.
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
        helper.updateItems(component);
    },

    doAddIP: function (component, event, helper) {
        component.find('actionIP').execute(null, function (vpId) {
            let vpIds = component.get('v.filter.pageFeatureIds');
            if(vpIds) vpIds += ';' + vpId;
            component.set('v.filter.pageFeatureIds', vpIds);
            helper.updateItems(component);
        }, 'create');
    },


    //Incentive Plan column actions: ---------------------------------------------------------------------------------------
    columnCheckboxStateChange: function (component, event, helper) {
        let vpId = event.target.dataset.vp;
        let state = event.target.dataset.state === 'Enabled';
        component.find('spinner').show();
        communityService.executeAction(component, 'setIncentivePlanForAll', {
            visitPlanId: vpId,
            state: state,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination')),
            ssItemsJSON: JSON.stringify(component.get('v.ssItems'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    },

    doColumnIPEdit: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionIP').execute(menuCmp.get('v.plan').value, function () {
            helper.updateItems(component);
        }, 'edit');
    },

    doColumnIPView: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionIP').execute(menuCmp.get('v.plan').value, function () {
            helper.updateItems(component);
        }, 'view');
    },

    doColumnIPClone: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionIP').execute(menuCmp.get('v.plan').value, function () {
            helper.updateItems(component);
        }, 'clone');
    },

    doColumnIPDelete: function (component, event, helper) {
        let menuCmp = event.getSource();
        let planId = menuCmp.get('v.plan').value;
        let ipIds = component.get('v.filter.pageFeatureIds');
        if (ipIds) {
            let items = ipIds.split(';');
            let resItems = [];
            for (let i = 0; i < items.length; i++) {
                if (items[i] !== planId) resItems.push(items[i]);
            }
            component.set('v.filter.pageFeatureIds', resItems.join(';'));
        }
        component.find('spinner').show();
        communityService.executeAction(component, 'deleteIncentivePlan', {
            planId: planId,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    }
});