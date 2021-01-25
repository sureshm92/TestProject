({
    callhandleSectionToggle: function (component, event, helper)  {
        if(component.get('v.sectionOpen')){
            component.set('v.sectionOpen',false);
        }else{
            component.set('v.sectionOpen',true);
        }
        //alert(component.get('v.sectionOpen'));
        component.find('calldispositionlwc').Refresh();
    },
    handleNewCall: function (component, event, helper)  {
        //alert(component.get('v.sectionOpen'));
        if(component.get('v.sectionOpen')){
            component.find("accordioncd").set('v.activeSectionName', 'CD');
        }
        //component.set('v.isCDValitated',false);
        
         if($A.util.isEmpty(component.get('v.notes')))
        {
            
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',false);console.log('okay');
                }else{
                    component.set('v.isCDValitated',true);console.log('t');
                }
                
            }else{component.set('v.isCDValitated',false);console.log('notokay');}
            
        }else{
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',true);console.log('okay');
                }else{
                    component.set('v.isCDValitated',true);console.log('t');
                }
                
            }else{component.set('v.isCDValitated',false);console.log('notokay');}
        }       
        
        component.set('v.newCall',true);
        component.find('calldispositionlwc').newCall();
      
    },
    getValueFromLwc : function(component, event, helper) {
        component.set("v.notes",event.getParam('value'));
        //alert('LWC to Aura');
        console.log('aurainputval'+component.get('v.notes'));
        
        if($A.util.isEmpty(component.get('v.notes')))
        {
            
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',false);console.log('okay');
                }else{
                    component.set('v.isCDValitated',true);console.log('t');
                }
                
            }else{component.set('v.isCDValitated',false);console.log('notokay');}
            
        }else{
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',true);console.log('okay');
                }else{
                    component.set('v.isCDValitated',true);console.log('t');
                }
                
            }else{component.set('v.isCDValitated',false);console.log('notokay');}
        }       
        
    },
    getcallcategValueFromLwc : function(component, event, helper) {
        component.set("v.callcategory",event.getParam('value'));
        //alert('LWC to Aura');
        console.log('aura'+component.get('v.callcategory'));
        var intervionReq = component.get('v.interventionReq');
        if(intervionReq)
        {
            var notes = component.get('v.notes');
            console.log(notes);
            console.log($A.util.isEmpty(notes));
            if($A.util.isEmpty(notes)){console.log('notes  empty');
                                       component.set('v.isCDValitated',false);
                                      }else{ component.set('v.isCDValitated',true);console.log('notes not  empty');}
            
        }else{
            component.set('v.isCDValitated',true);console.log('intervion true');
        }
    },
    validationNotrequired : function(component, event, helper) {
        component.set('v.isCDValitated',true);
        component.set('v.callcategory','');
        component.set('v.callbound','Inbound');
        component.set('v.interventionReq',false);
        component.set('v.notes','');
        component.set('v.newCall',false);
    },
    getcallBound : function(component, event, helper) {
        component.set('v.callbound',event.getParam('value'));
        console.log('aura'+component.get('v.callbound'));
    },
    getinterventionchange : function(component, event, helper) {
        var interReq = event.getParam('value');
        var notes = component.get('v.notes');
        component.set('v.interventionReq',interReq);
        console.log('aura'+component.get('v.interventionReq'));
        console.log(!$A.util.isEmpty(component.get('v.callcategory')));
        console.log(!$A.util.isEmpty(component.get('v.notes')));
        if(interReq)
        {
            if(!$A.util.isEmpty(notes))
            {
                if(!$A.util.isEmpty(component.get('v.callcategory')))
                {
                    component.set('v.isCDValitated',true);console.log('okay');
                }else{component.set('v.isCDValitated',false);console.log('notokay');}
                
            }else{ component.set('v.isCDValitated',false);console.log('notesempty');}
        }else{
            if($A.util.isEmpty(component.get('v.callcategory')))
            {
                component.set('v.isCDValitated',false);
            }else{ component.set('v.isCDValitated',true);}
            
        }
    },
    
})