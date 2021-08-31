({  
    doInit : function(component, event, helper) {
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getMedicalHistory");
        component.set('v.subDomain', communityService.getSubDomain());        
        action.setParams({ peId : peId });
        action.setCallback(this, function(response) 
                           {
                               //console.log('Test9' +response.getReturnValue());
                               component.set('v.medicalHistory', JSON.parse(response.getReturnValue()));
                               var MD =component.get('v.medicalHistory');
                               //console.log('MED123' +JSON.stringify(MD));
                               var CreatedDate =MD.attachments[0].CreatedDate
                               //Console.log('MED12345' +JSON.stringify(CreatedDate));
                            //    component.set('v.CreatedDate' , Date.parse(CreatedDate));
                               component.set('v.CreatedDate' , $A.localizationService.formatDate(CreatedDate, 'MMM dd, yyyy, hh:mm a'));
                               //console.log('MED123456789' +JSON.stringify(Date.parse(CreatedDate)));
                               
                               
                           });
        $A.enqueueAction(action);
        
    },
    openModel : function(component, event, helper){       
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getMedicalHistory");
        action.setParams({ peId : peId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') 
            {
                var responseData = JSON.parse(response.getReturnValue());                
                if (responseData.attachments[0].ContentSize < 11534336 ) //In Bytes(in binary)
                {                  
                    component.set('v.openmodel',true);
                } 
                else 
                {
                    component.set('v.openmodel',false);
                    helper.showToast(component, event, helper );
                }
            }   
        });
        $A.enqueueAction(action);
    },
    
    closeModal:function(component,event,helper){    
        component.set('v.openmodel',false);
    },
    
    
})