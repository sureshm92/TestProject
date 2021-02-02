({
    doUpdateSelection: function (component, event, helper) {
        helper.doUpdateSelectionHelper(component);
    },
    doSearch: function (component, event, helper) {
        helper.doSearchHelper(component);
    },
    doReset: function (component, event, helper) {
        let parent = component.get('v.parent');
        parent.doRefesh(true);
    },
    doExportAll: function (component, event, helper) {
        let selectedSearchOption = component.get('v.selectedSearchOption');
        let searchText = component.get('v.searchText');
        let parent = component.get('v.parent');
        searchText = searchText.trim();
        if (!searchText || !selectedSearchOption) {
            communityService.showErrorToast('Error', 'Search text required!');
            return;
        } else {
            parent.callExportAll(selectedSearchOption, searchText);
        }
    },
    doUpdateSortType: function (component, event, helper) {
        if (component.get('v.resetVal')) return;
        helper.doSearchHelper(component);
    },
    onKeyUp: function (component, event, helper) {
        if (event.which === 13) {
            helper.doSearchHelper(component);
        }
    }
});
