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
        //TO DO
    },
    doUpdateSortType: function (component, event, helper) {
        if (component.get('v.resetVal')) return;
        helper.doSearchHelper(component);
    }
});
