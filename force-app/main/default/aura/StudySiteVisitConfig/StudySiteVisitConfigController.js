/**
 * Created by Igor Malyuta on 18.09.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (data) {
            component.set('v.viewModePage', data.viewMode);
            helper.init(component, data);
        });
    },

    doLoadNextData: function (component, event, helper) {
        if (event.getParam('oldValue') === undefined) return;

        var data = component.get('v.data');
        data.paginationData.currentPage = component.get('v.currentPage');

        var cCodes = component.get('v.countryCodes');
        var selectedVPIds = component.get('v.selectedVPIds');
        var selectedSSIds = component.get('v.selectedSSIds');

        component.find('spinner').show();

        communityService.executeAction(component, 'getNextData', {
            data: JSON.stringify(data),
            countryCodes: cCodes,
            selectedVPIds: selectedVPIds,
            ssId: selectedSSIds,
        }, function (response) {
            component.set('v.data', response);
            component.set('v.ssItems', response.studySiteItems);
            component.set('v.haveEmptyVPSS', response.haveEmptyVPSS);

            component.find('spinner').hide();
        });
    },

    onCountriesChange: function (component, event, helper) {
        var ccCodes = component.get('v.countryCodes').split(';');
        var newSelectedSSIds = new Set();

        var count = 0;
        var items = component.get('v.ssItems');
        for (let i = 0; i < items.length; i++) {
            if (ccCodes.indexOf(items[i].ss.Site__r.BillingCountryCode) > -1) {
                newSelectedSSIds.add(items[i].ss.Id);
                count++;
            }
        }

        var newSSIds = Array.from(newSelectedSSIds).join(';');
        if (count === items.length) newSSIds = '';

        component.set('v.selectedSSIds', newSSIds);

        component.find('spinner').show();
        helper.updateTable(component);
    },

    getFilteredSS: function (component, event, helper) {
        component.find('spinner').show();
        helper.updateTable(component);
    },

    doSort: function (component, event, helper) {
        var sortDirection = true;
        var order;

        if (event) {
            event.preventDefault();
            order = event.currentTarget.dataset.order;
            if (order === 'country') {
                sortDirection = !component.get('v.countrySortType');
                component.set('v.countrySortType', sortDirection);
            } else if (order === 'name') {
                sortDirection = !component.get('v.nameSortType');
                component.set('v.nameSortType', sortDirection);
            } else if (order === 'number') {
                sortDirection = !component.get('v.numberSortType');
                component.set('v.numberSortType', sortDirection);
            }
            component.set('v.sortOrder', order);

            component.find('spinner').show();
            communityService.executeAction(component, 'getSortedItems', {
                data: JSON.stringify(component.get('v.data')),
                selectedVPIds: component.get('v.selectedVPIds'),
                sortOrder: order,
                sortDirection: sortDirection
            }, function (data) {
                component.set('v.ssItems', data.studySiteItems);
                component.find('spinner').hide();
            });
        }
    },

    doSave: function (component, event, helper) {
        var data = component.get('v.data');
        data.studySiteItems = component.get('v.ssItems');

        component.find('spinner').show();
        communityService.executeAction(component, 'save', {
            data: JSON.stringify(data)
        }, function (data) {
            component.set('v.haveEmptyVPSS', data.haveEmptyVPSS);
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Changes were saved!');
        });
    },

    doAddVP: function (component, event, helper) {
        component.find('actionVP').execute(null, function () {
            component.refresh();
        }, 'create');
    },

    whenCountryFilterChanged: function (component, event, helper) {
        var filterType = component.get('v.countryFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('countryLookup').focus();
                }), 100
            );
        }
    },

    whenVPFilterChanged: function (component, event, helper) {
        var filterType = component.get('v.vpFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('vpLookup').focus();
                }), 100
            );
        }
    },

    whenSSFilterChanged: function (component, event, helper) {
        var filterType = component.get('v.sitesFilterType');
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
        var lang = event.getParam('keyId');
        var state = event.getParam('value');

        var ssItems = component.get('v.ssItems');
        for (var i = 0; i < ssItems.length; i++) {
            var asgCount = 0;
            var assignments = ssItems[i].assignments;
            for (var j = 0; j < assignments.length; j++) {
                if (assignments[j].value === lang) {
                    ssItems[i].assignments[j].state = state;
                }
                if (assignments[j].state) asgCount++;
            }

            ssItems[i].emptyAssignments = asgCount === 0;
        }

        component.set('v.ssItems', ssItems);
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
            ctpId: component.get('v.recordId')
        }, function (data) {
            helper.init(component, data);
        });
    }
});