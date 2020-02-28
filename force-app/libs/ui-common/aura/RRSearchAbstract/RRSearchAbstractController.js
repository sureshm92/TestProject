/**
 * Created by Leonid Bartenev
 */
({
    onInput: function (component, event, helper) {
        var searchTerm = event.target.value;
        component.set('v.searchTerm', searchTerm);
        helper.search(component);
    },

    doValueChange: function (component, event, helper) {
        if (component.get('v.bypassValueChange')) return;
        var value = component.get('v.value');
        if (!value) {
            component.set('v.selection', []);
            component.set('v.loading', false);
            component.set('v.showSpinner', false);
        } else {
            component.getConcreteComponent().searchByValue(function (selection) {
                helper.updateSelection(component, selection);
                component.set('v.loading', false);
                component.set('v.showSpinner', false);
            });
        }
    },

    onResultClick: function (component, event, helper) {
        var itemIndex = event.currentTarget.dataset.itemIndex;
        var searchResults = component.get('v.searchResults');
        var selection = component.get('v.selection');
        selection.push(searchResults[itemIndex]);
        component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
        helper.updateSelection(component, selection);
        helper.copySelectionToValue(component);
        helper.enqueueOnChangeAction(component);
    },

    onRemoveSelectedItem: function (component, event, helper) {
        var itemId = event.getSource().get('v.name');
        var selection = component.get('v.selection');
        var updatedSelection = selection.filter(function (item) {
            return item.id !== itemId;
        });
        helper.updateSelection(component, updatedSelection);
        helper.copySelectionToValue(component);
        helper.enqueueOnChangeAction(component);

    },

    onClearSelection: function (component, event, helper) {
        helper.updateSelection(component, []);
        helper.copySelectionToValue(component);
        helper.enqueueOnChangeAction(component);
    },

    onComboboxClick: function (component, event, helper) {
        component.set('v.hasFocus', false);
    },

    onFocus: function (component, event, helper) {
        if (!helper.isSelectionAllowed(component)) return;
        component.set('v.hasFocus', true);
        if (component.get('v.minTermLength') === 0) helper.search(component);
    },

    onBlur: function (component, event, helper) {
        if (!helper.isSelectionAllowed(component)) return;
        setTimeout(
            $A.getCallback(function () {
                component.set('v.hasFocus', false);
                var blurAction = component.get('v.onblur');
                if (blurAction) $A.enqueueAction(blurAction);

            }), 150
        );
    },

    doFocus: function (component) {
        setTimeout(
            $A.getCallback(function () {
                var element = document.getElementById(component.getGlobalId() + '_combobox');
                if (element) element.focus();
            }), 100
        );
    }


})