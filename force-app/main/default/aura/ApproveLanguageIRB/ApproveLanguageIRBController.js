/**
 * Created by Igor Malyuta on 22.08.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (data) {
            component.set('v.filter', data.filter);
            component.set('v.viewModePage', data.viewMode);

            let pageWrapper = data.pageWrapper;
            component.set('v.pageWrapper', pageWrapper);
            component.set('v.ssItems', pageWrapper.studySiteItems);
            component.set('v.languages', pageWrapper.pageColumnItems);
            component.set('v.allRecordsCount', pageWrapper.pagination.allRecordsCount);
            component.set('v.pageRecordsCount', pageWrapper.pagination.pageRecordsCount);
            component.set('v.currentPage', pageWrapper.pagination.currentPage);

            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    doLoadNextData: function (component, event, helper) {
        if (event.getParam('oldValue') === undefined) return;

        let pageWrapper = component.get('v.pageWrapper');
        pageWrapper.pagination.currentPage = component.get('v.currentPage');

        helper.updateSorting(component);
        component.find('spinner').show();

        communityService.executeAction(component, 'getNextData', {
            wrapper: JSON.stringify(pageWrapper),
            filter: JSON.stringify(component.get('v.filter'))
        }, function (response) {
            component.set('v.pageWrapper', response);
            component.set('v.ssItems', response.studySiteItems);

            component.find('spinner').hide();
        });
    },

    onCountriesChange: function (component, event, helper) {
        var filter = component.get('v.filter');
        let ccCodes = filter.countryCodes.split(';');
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

        filter.selectedSSIds = newSSIds;
        component.set('v.filter', filter);

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
                wrapper: JSON.stringify(component.get('v.pageWrapper')),
                filter: JSON.stringify(component.get('v.filter'))
            }, function (response) {
                component.set('v.ssItems', JSON.parse(response));
                component.find('spinner').hide();
            });
        }
    },

    doSave: function (component, event, helper) {
        let pageWrapper = component.get('v.pageWrapper');
        pageWrapper.studySiteItems = component.get('v.ssItems');

        component.find('spinner').show();
        communityService.executeAction(component, 'save', {
            wrapper: JSON.stringify(pageWrapper),
            filter: JSON.stringify(component.get('v.filter'))
        }, function (response) {
            component.set('v.pageWrapper', response);
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
            filter: JSON.stringify(component.get('v.filter')),
            language: lang,
            state: state
        }, function () {
            helper.updateTable(component, helper);
        });
    }
});