({
    doUpdateSelectionHelper: function (component) {
        let option = component.get('v.selectedSearchOption');
        if (option !== '') {
            component.set('v.sectionDisabled', false);
            component.set('v.searchTextPlaceHolder', $A.get('$Label.c.CC_SearchPlaceholder'));
        }
    },
    doSearchHelper: function (component) {
        let selectedSearchOption = component.get('v.selectedSearchOption');
        let searchText = component.get('v.searchText');
        let sortType = component.get('v.sortType');
        let parent = component.get('v.parent');
        searchText = searchText.trim();
        if (!searchText || !selectedSearchOption) {
            //communityService.showErrorToast('Error', $A.get('$Label.c.CC_SearchTxtRequired'));
            component.set('v.containsSerchTxt', false);
            return;
        } else {
            component.set('v.containsSerchTxt', true);
            parent.callDatabaseSearch(selectedSearchOption, searchText, sortType);
        }
    }
});
