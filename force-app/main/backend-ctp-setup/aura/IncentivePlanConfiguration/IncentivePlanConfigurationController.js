/**
 * Created by Alexey Moseev on 5/7/20.
 */

({
    doInit: function (component, event, helper) {
        console.log('DOINIT');
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (initData) {
            component.set('v.filter', initData.filter);
            component.set('v.viewModePage', initData.viewMode);
            component.set('v.tasks', initData.listWrapper)
            component.set('v.studyInfo', initData.infoStudy)
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
        component.find('actionIP').execute(null, function (ipId) {
            let ipIds = component.get('v.filter.pageFeatureIds');
            if (ipIds) ipIds += ';' + ipId;
            component.set('v.filter.pageFeatureIds', ipIds);
            helper.updateItems(component);
        }, 'create');
    },


    //Incentive Plan column actions: ---------------------------------------------------------------------------------------

    doCheckboxChange: function (component, event, helper){
        let ipId = event.target.dataset.ip;
        let state = event.target.dataset.state === 'Enabled';
        component.set('v.ipId', ipId);
        component.set('v.state', state);
        component.find('warningModal').show(($A.get('$Label.c.PG_Ref_L_One_Incentive_Many_Incentives')).replace('{0}', ('' + component.get('v.ssItems').length)), true);
    },

    columnCheckboxStateChange: function (component, event, helper) {
        let ipId = component.get('v.ipId');
        let state = component.get('v.state');

        let haveSelecteAll = false;
        let allSelectedIPs = component.get('v.allSelectedIPs');
        for (const incenitvePlan in allSelectedIPs) {
            haveSelecteAll = haveSelecteAll || allSelectedIPs[incenitvePlan] && allSelectedIPs[incenitvePlan].size && incenitvePlan !== ipId;
        }

        if (!haveSelecteAll || !state) {
            component.find('spinner').show();
            communityService.executeAction(component, 'setIncentivePlanForAll', {
                incentivePlanId: ipId,
                state: state,
                filterJSON: JSON.stringify(component.get('v.filter')),
                paginationJSON: JSON.stringify(component.get('v.pagination')),
                ssItemsJSON: JSON.stringify(component.get('v.ssItems'))
            }, function (searchResponse) {
                helper.setSearchResponse(component, searchResponse);
                if (state) {
                    let setOfSS = component.get('v.setOfSS');
                    allSelectedIPs[ipId] = new Set(Array.from(setOfSS));
                    component.set('v.allSelectedIPs', allSelectedIPs);
                } else {
                    allSelectedIPs[ipId].clear();
                    component.set('v.allSelectedIPs', allSelectedIPs);
                }
                component.find('warningModal').hide();
            });
        } else if (state && haveSelecteAll) {
            communityService.showWarningToast('Warning!', $A.get('$Label.c.PG_Ref_L_One_Incentive_Plan'), 5000);
            component.find('warningModal').hide();
        }
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

    doWarningModal: function (component, event, helper) {
        let menuCmp = event.getSource();
        let planId = menuCmp.get('v.plan').value;
        communityService.executeAction(component, 'getNumberStudySites', {
            planId: planId
        }, function (returnvalue) {
            component.set('v.planIdForDelete', planId);
            component.find('warningModal').show(($A.get('$Label.c.PG_Ref_L_Text_To_Delete_Plan')).replace('{0}', ('' + returnvalue)), false);
        });
    },
    doColumnIPDelete: function (component, event, helper) {
        let planId = component.get('v.planIdForDelete');
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
            component.find('warningModal').hide();
        });
    }

});