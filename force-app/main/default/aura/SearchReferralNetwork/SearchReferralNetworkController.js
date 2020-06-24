({
	 doInit: function (component, event, helper) {
          
        communityService.executeAction(component, 'getReferralNetworkRecords', {
            sObjectType: component.get("v.sObjectType")
        }, function (returnValue) {
            console.log('returnValue' + JSON.stringify(returnValue));
      
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
          // component.set('v.records', null);
        
    },
    
      handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },
    
      handleRemoveOnly: function (component, event,helper) {
        event.preventDefault();
        helper.handleClearPill(component,event,helper); 
          var ddown = component.find('dropdown');
          $A.util.toggleClass(ddown, 'slds-hide');  
        }
    ,
   
    
    
})