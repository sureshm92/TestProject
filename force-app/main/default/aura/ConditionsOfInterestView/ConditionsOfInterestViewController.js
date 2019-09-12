({

    doInit : function(component, event, helper) {
        if (!component.get('v.initialized')) {
            component.set('v.initialized', true);
            let taps = component.get('v.taps');
            for (let i = 0; i < taps.length; i++) {
                taps[i].checked = true;
            }
            component.set('v.taps', taps);
        }
    },

    doSearch : function(component, event, helper) {
        helper.doSearch(component);
    },

    onFocus : function(component, event, helper) {
        let searchContainer = component.find('searchContainer');
        $A.util.addClass(searchContainer, 'slds-is-open');
        helper.doSearch(component);
    },

    onBlur :function(component, event, helper) {
        setTimeout(function () {
            let searchContainer = component.find('searchContainer');
            $A.util.removeClass(searchContainer, 'slds-is-open');
        }, 100)
    },

    handleSelection : function(component, event, helper) {
        helper.handleSelection(component, event, helper);
    },

    updateSearchResults : function(component, event, helper) {
        // communityService.executeAction(component, 'upsertTaps', {
        //     taps : component.get('v.taps')
        // }, function () {
        helper.updateSearchResults(component);
        // });
    }

});