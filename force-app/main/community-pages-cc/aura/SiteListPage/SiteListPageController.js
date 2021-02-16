({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            let searchList = [
                { label: $A.get('$Label.c.CC_StudySiteName'), value: 'Name' },
                //To make the query indexed
                {
                    label: $A.get('$Label.c.CC_ProtocolNumber'),
                    value: 'Clinical_Trial_Profile__r.Protocol_ID__c'
                },
                { label: $A.get('$Label.c.CC_SiteNumber'), value: 'Study_Site_Number__c' },
                { label: $A.get('$Label.c.CC_PI_Name'), value: 'Principal_Investigator__r.Name' }
            ];
            let sortVariants = [
                { label: 'Site Alphabetical (a-z)', value: 'Name ASC' },
                { label: 'Site Alphabetical (z-a)', value: 'Name DESC' },
                { label: 'Site Number (Ascending)', value: 'Study_Site_Number__c ASC' },
                { label: 'Site Number (Descending)', value: 'Study_Site_Number__c DESC' }
            ];
            let resultSet = [];
            spinner.show();
            let params = event.getParam('arguments');
            if (params && params.resetVal) {
                component.set('v.resetVal', true);
            }
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.isInitialized', true);
            component.set('v.searchList', searchList);
            component.set('v.sortVariants', sortVariants);
            component.set('v.sectionDisabled', true);
            component.set('v.searchTextPlaceHolder', $A.get('$Label.c.CC_Btn_Search'));
            component.set('v.sortType', 'Name ASC');
            component.set('v.searchText', '');
            component.set('v.selectedSearchOption', '');
            component.set('v.resultSet', resultSet);
            component.set('v.filterStudyName', '');
            component.set('v.filterCountry', '');
            component.set('v.searched', false);
            spinner.hide();
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },
    doDatabaseSearch: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText && params.sortType) {
            helper.doDatabaseSearchHelper(component, event, params);
        }
    },
    doExportAllSearchResults: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText) {
            helper.doExportAllHelper(component, helper, params);
        }
    }
});
