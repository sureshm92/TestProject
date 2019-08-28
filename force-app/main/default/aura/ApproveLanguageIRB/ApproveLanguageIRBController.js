/**
 * Created by Igor Malyuta on 22.08.2019.
 */

({
    doInit : function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            'ctpId' : component.get('v.recordId')
        }, function (data) {
            console.log('Data: ' + JSON.stringify(data));

            component.set('v.ssItems', data.studySiteItems);
            component.set('v.countryCodes', data.countryCodes);
            component.set('v.languages', data.languages);
            component.set('v.initialized', true);

            // helper.setColumnCheckboxState(component);//Not work yet
            component.find('spinner').hide();
        });
    },

    getFilteredSS : function (component, event, helper) {
        var cCodes = component.get('v.countryCodes');
        if(!cCodes) component.set('v.countryFilterType', 'All');

        var langCodes = component.get('v.langCodes');
        if(!langCodes) component.set('v.langFilterType', 'All');

        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            'countryCodes' : cCodes,
            'langCodes' : langCodes,
            'ctpId' : component.get('v.recordId'),
            'ssId' : component.get('v.selectedSSIds')
        }, function (data) {
            component.set('v.ssItems', data.studySiteItems);
            component.set('v.languages', data.languages);

            // helper.setColumnCheckboxState(component);//Not work yet
            component.find('spinner').hide();
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

        var ssItems = component.get('v.ssItems');
        for(var i = 0; i < ssItems.length; i++) {
            var appLangs = ssItems[i].approvedLangCodes;
            for(var j = 0; j < appLangs.length; j++) {
                if(appLangs[j].value === lang) {
                    ssItems[i].approvedLangCodes[j].state = state;
                }
            }
        }

        component.set('v.ssItems', ssItems);
    },

    sscCheckboxStateChange : function (component, event, helper) {
        var keyId = event.getParam('keyId');
        var lang = event.getParam('field');
        var state = event.getParam('value');
        console.log('Lang: ' + lang + ' state: ' + state);

        var ssItems = component.get('v.ssItems');
        var selectedCount = 0;
        for(var i = 0; i < ssItems.length; i++) {
            var appLangs = ssItems[i].approvedLangCodes;
            for(var j = 0; j < appLangs.length; j++) {
                if(appLangs[j].value === lang && ssItems[i].ss.Id === keyId) {
                    ssItems[i].approvedLangCodes[j].state = state;
                }
                if(appLangs[j].value === lang && appLangs[j].state) {
                    selectedCount++;
                }
            }
        }

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

    doSave : function (component, event, helper) {
        console.log('Sites: ' + JSON.stringify(component.get('v.ssItems')));
        component.find('spinner').show();
        communityService.executeAction(component, 'save', {
            'items' : JSON.stringify(component.get('v.ssItems')),
            'ctpId' : component.get('v.recordId')
        }, function () {
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Changes was saved!');
        });
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