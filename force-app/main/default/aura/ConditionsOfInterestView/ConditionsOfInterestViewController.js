({

    doSearch : function(component, event, helper) {
        helper.doSearch(component);
    },

    onFocusIn : function(component, event, helper) {
        let searchContainer = component.find('searchContainer');
        $A.util.addClass(searchContainer, 'slds-is-open');
        helper.doSearch(component);
    },

    onFocusOut :function(component, event, helper) {
        let searchContainer = component.find('searchContainer');
        $A.util.removeClass(searchContainer, 'slds-is-open');
    },

    handleSelection : function(component, event, helper) {
        helper.handleSelection(component, event, helper);
    },

    updateSearchResults : function(component, event, helper) {
        helper.updateSearchResults(component);
    }

});