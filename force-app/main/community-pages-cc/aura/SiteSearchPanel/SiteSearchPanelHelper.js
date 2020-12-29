({
    doUpdateSelectionHelper: function (component) {
        debugger;
        let option = component.get('v.selectedSearchOption');
        if (option !== '') {
            component.set('v.sectionDisabled', false);
            component.set('v.searchTextPlaceHolder', $A.get('$Label.c.CC_SearchPlaceholder'));
        }
    }
});
