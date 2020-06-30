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
        var records = component.get('v.records');
        var selectedPills = new Map();
        var isChanged = false;
        selectedPills = component.get('v.selectedPills');
        var existingValues = component.get('v.existingValues');
        var selectedList=[];
       if(check) {
            records.push(value);
            selectedPills[value.Id] = value;
            isChanged = true;
            selectedList = records;
          
        } else {
            value.isSelected = false;
            selectedPills[value.Id] = value;
            isChanged = true;
            if(existingValues)
                for(var key in existingValues)
                    if(existingValues[value.Id])
                        if(existingValues[value.Id].Id == value.Id)
                        	isChanged = true;
             
            for (var i = 0; i < records.length; i++) 
                if (value.Id === records[i].Id) { 
                    var rec = records[i];
                    rec.isSelected = false;
                    selectedList.push(rec);
                } else
                    selectedList.push(rec);
            // records.splice(records.indexOf(value), 1 );
        }
        component.set('v.selectedPills',selectedPills); 
        component.set('v.records', records);
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
        var selectedList=[];
        var selectedPills = new Map();
       var isChanged = true;
       var existingValues = component.get('v.existingValues');
        selectedPills = component.get('v.selectedPills');
       var pillUpdate = pills;
        for (var i = 0; i < pills.length; i++) {
            if (pillName === pills[i].Id) { 
                pills[i].isSelected = false;
                selectedList.push(pills[i]);
                selectedPills[pills[i].Id] = pills[i];
              //  pillUpdate.splice(i, 1);
            } else 
                selectedList.push(pills[i]);
             }
       
        component.set('v.selectedPills', selectedPills);
        component.set('v.records', pillUpdate);
        component.find('searchInput').set('v.value', '');
        var cmpEvent = component.getEvent("SearchReferralNetworkResult"); 
        cmpEvent.setParams({"refResult" : selectedList,
                             "isChanged" : isChanged,
                            'sobjectName': component.get('v.sObjectType')}); 
        cmpEvent.fire(); 
    },
    
})