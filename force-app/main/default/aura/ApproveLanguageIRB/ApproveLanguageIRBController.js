/**
 * Created by Igor Malyuta on 22.08.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            'ctpId': component.get('v.recordId')
        }, function (data) {
            component.set('v.data', data);
            component.set('v.ssItems', data.studySiteItems);
            component.set('v.haveEmptyLangSS', data.haveEmptyLangSS);
            component.set('v.languages', data.languages);

            component.set('v.allRecordsCount', data.paginationData.allRecordsCount);
            component.set('v.pageRecordsCount', data.paginationData.pageRecordsCount);
            component.set('v.currentPage', data.paginationData.currentPage);

            component.set('v.initialized', true);
            component.find('spinner').hide();

            component.set('v.viewModePage', data.viewMode);
        });
    },

    doLoadNextData: function (component, event, helper) {
        if (event.getParam('oldValue') === undefined) return;

        let data = component.get('v.data');
        data.paginationData.currentPage = component.get('v.currentPage');

        component.set('v.sortOrder', 'name');

        let cCodes = component.get('v.countryCodes');
        let langCodes = component.get('v.langCodes');
        let selectedSSIds = component.get('v.selectedSSIds');

        component.find('spinner').show();

        communityService.executeAction(component, 'getNextData', {
            'data': JSON.stringify(data),
            'countryCodes': cCodes,
            'langCodes': langCodes,
            'ssId': selectedSSIds,
        }, function (response) {
            component.set('v.data', response);
            component.set('v.ssItems', response.studySiteItems);
            component.set('v.haveEmptyLangSS', response.haveEmptyLangSS);

            component.find('spinner').hide();
        });
    },

    onCountriesChange: function (component, event, helper) {
        let ccCodes = component.get('v.countryCodes').split(';');
        let newSelectedSSIds = new Set();

        let count = 0;
        let items = component.get('v.ssItems');
        for (let i = 0; i < items.length; i++) {
            if (ccCodes.indexOf(items[i].ss.Site__r.BillingCountryCode) > -1) {
                newSelectedSSIds.add(items[i].ss.Id);
                count++;
            }
        }

        let newSSIds = Array.from(newSelectedSSIds).join(';');
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
        let sortDirection = true;
        let order;

        if (event) {
            event.preventDefault();
            order = event.currentTarget.dataset.order;
            debugger;
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
                'data': JSON.stringify(component.get('v.data')),
                'langCodes': component.get('v.langCodes'),
                'sortOrder': order,
                sortDirection: sortDirection
            }, function (data) {
                component.set('v.ssItems', data.studySiteItems);
                component.find('spinner').hide();
            });
        }
    },

    doSave: function (component, event, helper) {
        let data = component.get('v.data');
        data.studySiteItems = component.get('v.ssItems');

        component.find('spinner').show();
        communityService.executeAction(component, 'save', {
            'data': JSON.stringify(data)
        }, function (data) {
            component.set('v.haveEmptyLangSS', data.haveEmptyLangSS);
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Changes were saved!');
        });
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

    whenLangFilterChanged: function (component, event, helper) {
        let filterType = component.get('v.langFilterType');
        if (filterType === 'filter') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('langsLookup').focus();
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

    columnCheckboxStateChange: function (component, event, helper) {
        let lang = event.target.dataset.lang;
        let state = event.target.dataset.state === 'Enabled';

        component.find('spinner').show();
        communityService.executeAction(component, 'setLanguageForAll', {
            data: JSON.stringify(component.get('v.data')),
            language: lang,
            state: state
        }, function () {
            helper.updateTable(component);
        });
    }
});