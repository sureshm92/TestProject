({
    doUpdateSelection: function (component, event, helper) {
        helper.doUpdateSelectionHelper(component);
    },
    doSearch: function (component, event, helper) {
        debugger;
        let selectedSearchOption = component.get('v.selectedSearchOption');
        let searchText = component.get('v.searchText');
        let sortType = component.get('v.sortType');
        let parent = component.get('v.parent');
        if (!searchText || !selectedSearchOption) {
            communityService.showErrorToast('Error', 'Search text required!');
            return;
        } else {
            parent.callDatabaseSearch(selectedSearchOption, searchText, sortType);
        }
    },
    doReset: function (component, event, helper) {
        let parent = component.get('v.parent');
        parent.doRefesh();
    },
    doExportAll: function (component, event, helper) {
        //TO DO
    }
});
