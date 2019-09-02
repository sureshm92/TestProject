/**
 * Created by Igor Malyuta on 22.08.2019.
 */

({
    doInit : function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            'ctpId' : component.get('v.recordId')
        }, function (data) {
            helper.initData(component, data);
            component.set('v.pageRecordsCount', data.paginationData.pageRecordsCount);
            component.set('v.currentPage', data.paginationData.currentPage);

            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    doLoadNextData : function (component, event, helper) {
        if(event.getParam('oldValue') === undefined) return;

        var data = component.get('v.data');
        data.paginationData.currentPage = component.get('v.currentPage');

        var cCodes = component.get('v.countryCodes');
        var langCodes = component.get('v.langCodes');
        var selectedSSIds = component.get('v.selectedSSIds');

        component.find('spinner').show();

        communityService.executeAction(component, 'getNextData', {
            'data' : JSON.stringify(data),
            'countryCodes' : cCodes,
            'langCodes' : langCodes,
            'ssId' : selectedSSIds,
        }, function (response) {
            component.set('v.data', response);
            component.set('v.ssItems', response.studySiteItems);
            component.set('v.haveEmptyLangSS', response.haveEmptyLangSS);

            component.find('spinner').hide();
        });
    },

    getFilteredSS : function (component, event, helper) {
        var data = component.get('v.data');
        var cCodes = component.get('v.countryCodes');
        if(!cCodes) {
            component.set('v.countryFilterType', 'All');
            // component.set('v.countryCodes', data.countryCodes);
        }

        var langCodes = component.get('v.langCodes');
        if(!langCodes) component.set('v.langFilterType', 'All');

        if(event) {
            var order = event.currentTarget.dataset.order;
            if(order === 'country') {
                component.set('v.countrySortType', !component.get('v.countrySortType'));
            } else if(order === 'name') {
                component.set('v.nameSortType', !component.get('v.nameSortType'));
            } else if(order === 'number') {
                component.set('v.numberSortType', !component.get('v.numberSortType'));
            }
            component.set('v.sortOrder', order);
        }

        var selectedSSIds = component.get('v.selectedSSIds');

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            'data' : JSON.stringify(data),
            'countryCodes' : cCodes,
            'langCodes' : langCodes,
            'ssId' : selectedSSIds,
            'sortOrder' : component.get('v.sortOrder')
        }, function (data) {
            component.set('v.ssItems', data.studySiteItems);
            component.set('v.haveEmptyLangSS', data.haveEmptyLangSS);

            component.set('v.allRecordsCount', data.paginationData.allRecordsCount);
            component.set('v.currentPage', data.paginationData.currentPage);
            component.set('v.languages', data.languages);

            component.find('spinner').hide();
        });
    },

    doSave : function (component, event, helper) {
        var data = component.get('v.data');
        data.studySiteItems = component.get('v.ssItems');

        component.find('spinner').show();
        communityService.executeAction(component, 'save', {
            'data' : JSON.stringify(data)
        }, function () {
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Changes was saved!');
        });
    },

    whenCountryFilterChanged : function (component, event, helper) {
        var filterType = component.get('v.countryFilterType');
        if(filterType === 'filter'){
            setTimeout(
                $A.getCallback(function () {
                    component.find('countryLookup').focus();
                }), 100
            );
        }
    },

    whenLangFilterChanged : function (component, event, helper) {
        var filterType = component.get('v.langFilterType');
        if(filterType === 'filter'){
            setTimeout(
                $A.getCallback(function () {
                    component.find('langsLookup').focus();
                }), 100
            );
        }
    },

    columnCheckboxStateChange : function (component, event, helper) {
        var lang = event.getParam('keyId');
        var state = event.getParam('value');

        // var haveEmptyLng = false;
        var ssItems = component.get('v.ssItems');
        for(var i = 0; i < ssItems.length; i++) {
            var appCount = 0;
            var appLangs = ssItems[i].approvedLangCodes;
            for(var j = 0; j < appLangs.length; j++) {
                if(appLangs[j].value === lang) {
                    ssItems[i].approvedLangCodes[j].state = state;
                }
                if(appLangs[j].state) appCount++;
            }

            // ssItems[i].emptyAppLangs = appCount === 0;
            // if(ssItems[i].emptyAppLangs) haveEmptyLng = true;
        }

        // component.set('v.haveEmptyLangSS', haveEmptyLng);
        component.set('v.ssItems', ssItems);
    },

    sscCheckboxStateChange : function (component, event, helper) {
        var keyId = event.getParam('keyId');
        var lang = event.getParam('field');
        var state = event.getParam('value');
        // console.log('Lang: ' + lang + ' state: ' + state);

        var ssItems = component.get('v.ssItems');
        // var haveEmptyLng = false;
        var selectedCount = 0;
        for(var i = 0; i < ssItems.length; i++) {
            var appLangs = ssItems[i].approvedLangCodes;
            var appCount = 0;
            for(var j = 0; j < appLangs.length; j++) {
                if(appLangs[j].value === lang){
                    if(ssItems[i].ss.Id === keyId) appLangs[j].state = state;
                    if(appLangs[j].state) selectedCount++;
                }
                if(appLangs[j].state) appCount++;
            }
            // ssItems[i].emptyAppLangs = appCount === 0;
            // if(ssItems[i].emptyAppLangs) haveEmptyLng = true;
        }
        component.set('v.ssItems', ssItems);
        // component.set('v.haveEmptyLangSS', haveEmptyLng);

        var langColumnState = 'none';
        if(selectedCount === ssItems.length) {
            langColumnState = 'all';
        } else if(selectedCount > 0 && selectedCount < ssItems.length) {
            langColumnState = 'indeterminate';
        }

        var langColumns = component.find('columnLang');
        for(var k = 0; k < langColumns.length; k++) {
            var column = langColumns[k];
            if(column.get('v.keyId') === lang) {
                switch (langColumnState) {
                    case 'all':
                        column.setState(true, false);
                        break;
                    case 'indeterminate':
                        column.setState(false, true);
                        break;
                    default:
                        column.setState(false, false);
                }
                break;
            }
        }
    },

    viewStudySite : function (component, event, helper) {
        var ssId = event.currentTarget.dataset.ssid;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Study_Site__c',
                recordId : ssId
            },
        };

        component.find('navLink').navigate(pageRef);
    }
});