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
        /*let selectedSearchOption = component.get('v.selectedSearchOption');
        let searchText = component.get('v.searchText');
        let parent = component.get('v.parent');
        searchText = searchText.trim();
        if (!searchText || !selectedSearchOption) {
            //communityService.showErrorToast('Error', $A.get('$Label.c.CC_SearchTxtRequired'));
            component.set('v.containsSerchTxt', false);
            return;
        } else {
            component.set('v.containsSerchTxt', true);
            parent.callExportAll(selectedSearchOption, searchText);
        }*/
        return false;
    },
    doUpdateSortType: function (component, event, helper) {
        if (component.get('v.resetVal')) return;
        helper.doSearchHelper(component);
    },
    onKeyUp: function (component, event, helper) {
        if (event.which === 13) {
            helper.doSearchHelper(component);
        }
    },
    doCheckSearchTxt: function (component, event, helper) {
        let searchText = component.get('v.searchText');
        if (searchText && searchText.length > 0 && !component.get('v.containsSerchTxt')) {
            component.set('v.containsSerchTxt', true);
        }
    }
});
