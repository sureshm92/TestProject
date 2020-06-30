({
    doSearch: function (component, event, helper) {
        let value = event.getSource().get('v.value');
          component.set('v.showSpinner',true);
        communityService.executeAction(component, 'searchForReferralNetworks', {
            term: value,
            sObjectType: component.get('v.sObjectType')
        }, function (returnValue) {
            if(returnValue) {
                var rec = [];
                var selectedPills = component.get('v.selectedPills');
                 for(var i in returnValue) { 
                    if(selectedPills) {
                        if(selectedPills[returnValue[i].Id]) {
                            if(selectedPills[returnValue[i].Id].isSelected ===  true) 
                                returnValue[i].isSelected =  true;
                            else
                                returnValue[i].isSelected =  false;
                        } else
                            returnValue[i].isSelected =  false;
                    } else
                        returnValue[i].isSelected =  false;
                }
                 if(returnValue.length == 0) {
                    var ddown = component.find('dropdown');
                    $A.util.addClass(ddown, 'slds-hide');
                } else {
                    var ddown = component.find('dropdown');
                    $A.util.removeClass(ddown, 'slds-hide');
                }
            }
              component.set('v.showSpinner',false);
            component.set('v.displayedRefNetworks', returnValue);
        });
    },
    changeCheckBox: function (component, event) {
        var check = event.getSource().get("v.checked");
        var value = event.getSource().get("v.value");
        var selectedPills = component.get('v.selectedPills');
        var isChanged = true;
        var selectedList = [];
       if(check) {
           selectedPills[value.Id] = value;
        } else {
            value.isSelected = false;
            selectedPills[value.Id] = value;
        }
        if(selectedPills)
        for(var i in selectedPills)
            selectedList.push(selectedPills[i]);
        
        component.set('v.records', selectedList);
        var cmpEvent = component.getEvent("SearchReferralNetworkResult"); 
        //Set event attribute value
        cmpEvent.setParams({"refResult" : selectedList,
                            "isChanged" : isChanged,
                            'sobjectName': component.get('v.sObjectType')}); 
        cmpEvent.fire(); 
     
    },
   handleClearPill:function(component,event) {
        var pillName = event.getSource().get('v.name');
        var pills = component.get('v.records');
       var selectedPills = component.get('v.selectedPills');
       var isChanged = true;
       var selectedList = [];
       if(selectedPills)
           for(var i in selectedPills) 
               if(selectedPills[i].Id == pillName) {
                   selectedPills[i].isSelected = false;
                   selectedList.push(selectedPills[i]);
               } else
                   selectedList.push(selectedPills[i]);
      
        component.set('v.records', selectedList);
        component.find('searchInput').set('v.value', '');
        var cmpEvent = component.getEvent("SearchReferralNetworkResult"); 
        cmpEvent.setParams({"refResult" : selectedList,
                             "isChanged" : isChanged,
                            'sobjectName': component.get('v.sObjectType')}); 
        cmpEvent.fire(); 
    },
    
})