/**
 * Created by Leonid Bartenev
 */
({
    isSelectionAllowed : function(component) {
        return component.get('v.isMultiEntry') || component.get('v.selection').length === 0;
    },

    updateSelection: function (component, selection) {
        selection.sort(function (a, b) {
            if (a.id > b.id) {
                return 1;
            }
            if (a.id < b.id) {
                return -1;
            }
            return 0;
        });
        component.set('v.selection', selection);
   },

    search: function (component) {
        var searchTerm = component.get('v.searchTerm').replace(/[^a-zA-Z0-9-]/g, '\\');
        if (searchTerm.length < component.get('v.minTermLength')) {
            component.set('v.searchResults', []);
            return;
        }
        var selectedIds = [];
        var selection = component.get('v.selection');
        for (var i = 0; i < selection.length; i++) selectedIds.push(selection[i].id);
        component.set('v.showSpinner', true);
        component.getConcreteComponent().searchByTerm(function (searchResults) {
            const currentTerm = component.get('v.searchTerm');
            if (currentTerm !== searchTerm) return;
            component.set('v.searchResults', searchResults);
            component.set('v.showSpinner', false);
        });
    },

    copySelectionToValue: function (component) {
        var selection = component.get('v.selection');
        var items = [];
        for (var i = 0; i < selection.length; i++) items.push(selection[i].id);
        component.set('v.bypassValueChange', true);
        component.set('v.value', items.join(';'));
        component.set('v.bypassValueChange', false);
    },

    enqueueOnChangeAction: function (component) {
        var changeAction = component.get('v.onchange');
        if (changeAction) $A.enqueueAction(changeAction);
    }


})