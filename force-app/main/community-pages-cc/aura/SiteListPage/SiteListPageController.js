({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            spinner.show();
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.isInitialized', true);
            let searchList = [
                { label: $A.get('$Label.c.CC_StudySiteName'), value: 'Study Site Name' },
                { label: $A.get('$Label.c.CC_ProtocolNumber'), value: 'Protocol Number' },
                { label: $A.get('$Label.c.CC_SiteNumber'), value: 'Site Number' },
                { label: $A.get('$Label.c.CC_PI_Name'), value: 'PI Name' }
            ];
            let sortVariants = [
                { label: 'Site Alphabetical (a-z)', value: 'Name ASC' },
                { label: 'Site Alphabetical (z-a)', value: 'Name DESC' },
                { label: 'Site Number (Ascending)', value: 'Study_Site_Number__c ASC' },
                { label: 'Site Number (Descending)', value: 'Study_Site_Number__c DESC' }
            ];
            component.set('v.searchList', searchList);
            component.set('v.sortVariants', sortVariants);
            component.set('v.sectionDisabled', true);
            component.set('v.searchTextPlaceHolder', $A.get('$Label.c.CC_Btn_Search'));
            component.set('v.sortType', 'Name ASC');
            component.set('v.searchText', '');
            spinner.hide();
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },
    doExactSearch: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText && params.sortType) {
            window.alert('doExactSearch' + JSON.stringify(params));
        }
    },
    doPartialSearch: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params && params.selectedSearchOption && params.searchText && params.sortType) {
            window.alert('doPartialSearch' + JSON.stringify(params));
        }
    }
});
