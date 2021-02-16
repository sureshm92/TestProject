({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) {
            console.log('Not initialized');
            return;
        }
        if (!communityService.isDummy()) {
            let sortVariantArray = $A.get('$Label.c.CC_SortVariant').split(';');
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
                { label: sortVariantArray[0].trim(), value: 'Name ASC' }, //'Site Alphabetical (a-z)'
                { label: sortVariantArray[1].trim(), value: 'Name DESC' }, //'Site Alphabetical (z-a)'
                { label: sortVariantArray[2].trim(), value: 'Study_Site_Number__c ASC' }, //'Site Number (Ascending)'
                { label: sortVariantArray[3].trim(), value: 'Study_Site_Number__c DESC' } //'Site Number (Descending)'
            ];
            let emptyData = [];
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
            component.set('v.resultSet', emptyData);
            component.set('v.filteredResultSet', emptyData);
            component.set('v.exportList', emptyData);
            component.set('v.paginationData', null);
            component.set('v.searched', false);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
        component.find('mainSpinner').hide();
    },
    doDatabaseSearch: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText && params.sortType) {
            helper.doDatabaseSearchHelper(component, event, params);
        }
    },
    doExportAllSearchResults: function (component, event, helper) {
        /*let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText) {
            helper.doExportAllHelper(component, helper, params);
        }*/
        return false;
    },
    doPageNavigation: function (component, event, helper) {
        component.find('searchPanel').getSearchParams();
    }
});
