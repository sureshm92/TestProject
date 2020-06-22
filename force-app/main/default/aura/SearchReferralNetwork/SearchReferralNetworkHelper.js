({
    doSearch: function (component, event, helper) {
        console.log('hiii');
        let value = event.getSource().get('v.value');
        if (!value) {
            value = null;
        
        }
        communityService.executeAction(component, 'searchForReferralNetworks', {
            term: value,
            sObjectType: component.get('v.sObjectType')
        }, function (returnValue) {
            if(returnValue) {
                 var rec = [];
          
            for(var i in returnValue) {
                if(returnValue[i].isSelected ===  true)
                    rec.push(returnValue[i]);
            }    
            		component.set('v.records', rec);
                if(returnValue.length == 0) {
                    var ddown = component.find('dropdown');
                    $A.util.addClass(ddown, 'slds-hide');
                } else {
                      var ddown = component.find('dropdown');
                    $A.util.removeClass(ddown, 'slds-hide');
                }
                    
            }
            console.log(returnValue);
            component.set('v.displayedRefNetworks', returnValue);
        });
    },
    
     changeCheckBox: function (component, event) {
         var check = event.getSource().get("v.checked");
          var value = event.getSource().get("v.value");
         var records = component.get('v.records');
         console.log(value);
         console.log(check);
         if(check) 
         	records.push(value);
         else
            records.splice(records.indexOf(value), 1 );
           
         component.set('v.records', records);
        var cmpEvent = component.getEvent("SearchReferralNetworkResult"); 
        //Set event attribute value
        cmpEvent.setParams({"refResult" : records,
                            'sobjectName': component.get('v.sObjectType')}); 
        cmpEvent.fire(); 
         
    },
    handleClearPill:function(component,event){
        var pillName = event.getSource().get('v.name');
        var pills = component.get('v.records');
        var selectedList=[];
      
        for (var i = 0; i < pills.length; i++) {
            if (pillName === pills[i].Name) { 
                selectedList.push(pills[i]);
                pills.splice(i, 1);
                
                break;
            }
        }
      
        component.set('v.records', pills);
        component.find('searchInput').set('v.value', '');
        try {
         var cmpEvent = component.getEvent("SearchReferralNetworkResult"); 
      
        cmpEvent.setParams({"refResult" : pills,
                            'sobjectName': component.get('v.sObjectType')}); 
        cmpEvent.fire(); 
        } catch(e) {console.log(e.message);}
       // alert('event fired');
     
    },
   
})