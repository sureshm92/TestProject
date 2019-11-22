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
            component.set('v.languages', data.languages);

            component.set('v.allRecordsCount', data.searchWrapper.pagination.allRecordsCount);
            component.set('v.pageRecordsCount', data.searchWrapper.pagination.pageRecordsCount);
            component.set('v.currentPage', data.searchWrapper.pagination.currentPage);

            component.set('v.initialized', true);
            component.find('spinner').hide();

            component.set('v.viewModePage', data.viewMode);
        });
    },

    doLoadNextData: function (component, event, helper) {
        if (event.getParam('oldValue') === undefined) return;

        let data = component.get('v.data');
        data.searchWrapper.pagination.currentPage = component.get('v.currentPage');

        helper.updateSorting(component);
        component.find('spinner').show();

        communityService.executeAction(component, 'getNextData', {
            data: JSON.stringify(data)
        }, function (response) {
            component.set('v.data', response);
            component.set('v.ssItems', response.studySiteItems);

            component.find('spinner').hide();
        });
    },

    onCountriesChange: function (component, event, helper) {
        var data = component.get('v.data');
        let ccCodes = data.searchWrapper.filter.countryCodes.split(';');
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

        data.searchWrapper.filter.selectedSSIds = newSSIds;
        component.set('v.data', data);

        component.find('spinner').show();
        helper.updateTable(component, helper);
    },

    getFilteredSS: function (component, event, helper) {
        component.find('spinner').show();
        helper.updateTable(component, helper);
    },

    doSort: function (component, event, helper) {
        if (event) {
            event.preventDefault();
            let order = event.currentTarget.dataset.order;
            component.set('v.sortOrder', order);
            helper.updateSorting(component, true);

            component.find('spinner').show();
            communityService.executeAction(component, 'getSortedItems', {
                data: JSON.stringify(component.get('v.data'))
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
            data: JSON.stringify(data)
        }, function () {
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
            helper.updateTable(component, helper);
        });
    }
});