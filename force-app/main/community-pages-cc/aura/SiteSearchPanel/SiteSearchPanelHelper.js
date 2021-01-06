({
    doUpdateSelectionHelper: function (component) {
        debugger;
        let option = component.get('v.selectedSearchOption');
        if (option !== '') {
            component.set('v.sectionDisabled', false);
            component.set('v.searchTextPlaceHolder', $A.get('$Label.c.CC_SearchPlaceholder'));
        }
    },
    doSearchHelper: function (component) {
        debugger;
        console.log('doSearch');
        let selectedSearchOption = component.get('v.selectedSearchOption');
        let searchText = component.get('v.searchText');
        let sortType = component.get('v.sortType');
        let parent = component.get('v.parent');
        searchText = searchText.trim();
        if (!searchText || !selectedSearchOption) {
            communityService.showErrorToast('Error', 'Search text required!');
            return;
        } else {
            parent.callDatabaseSearch(selectedSearchOption, searchText, sortType);
        }
    }
});
