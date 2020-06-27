({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getReferralNetworkRecords', {
            sObjectType: component.get("v.sObjectType")
        }, function (returnValue) {
            var selectedPills = component.get('v.selectedPills');
            var selPills = [];
            for(var i in returnValue) {
                selPills.push(returnValue[i]);
                selPills[i].isSelected = true;
                selectedPills[selPills[i].Id] =  selPills[i];
            }
            component.set('v.selectedPills', selectedPills);
            component.set('v.records', returnValue);
        });  
    },
    
    bulkSearch: function (component, event, helper) {
        helper.doSearch(component, event, helper);
     },

    closeSearch: function (component, event, helper) {
        var ddown = component.find('dropdown');
        $A.util.addClass(ddown, 'slds-hide');
        component.find('searchInput').set('v.value', '');
    },
    
    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },
    
    handleRemoveOnly: function (component, event,helper) {
        event.preventDefault();
        helper.handleClearPill(component,event,helper); 
        
    }
    ,
    
    
    
})