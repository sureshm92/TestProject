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
    doRefreshSectionToggle: function (component, event, helper)  {
        if(component.get('v.sectionOpen')){
            component.set('v.sectionOpen',false);
        }else{
            component.set('v.sectionOpen',true);
        }
        component.set('v.isCDValitated',true);
        component.set('v.callcategory','');
        component.set('v.callbound','Inbound');
        component.set('v.interventionReq',false);
        component.set('v.notes','');
        component.set('v.newCall',false);
        component.set('v.isStudyInfoModified',false);
        console.log('calling lwc');
        component.find('calldispositionlwc').Refresh();
        
    },
    doRefreshSection: function (component, event, helper)  {
        if(component.get('v.sectionOpen')){
            component.set('v.sectionOpen',false);
        }else{
            component.set('v.sectionOpen',true);
        }
        component.set('v.isCDValitated',true);
        component.set('v.callcategory','');
        component.set('v.callbound','Inbound');
        component.set('v.interventionReq',false);
        component.set('v.notes','');
        component.set('v.newCall',false);
        component.set('v.isStudyInfoModified',false);
        console.log('calling lwc');
        component.find('calldispositionlwc').RefreshSection();
        
    },
    handleNewCall: function (component, event, helper)  {
        //alert(component.get('v.sectionOpen'));
        if(!component.get('v.sectionOpen')){
            component.find("accordioncd").set('v.activeSectionName', 'CD');
             component.set('v.sectionOpen',true);
        }
        //component.set('v.isCDValitated',false);
        component.set('v.isStudyInfoModified',true);
        if($A.util.isEmpty(component.get('v.notes')))
        {
            
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',false);
                }else{
                    component.set('v.isCDValitated',true);
                }
                
            }else{component.set('v.isCDValitated',false);
                 }
            
        }else{
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',true);
                }else{
                    component.set('v.isCDValitated',true);
                }
                
            }else{component.set('v.isCDValitated',false);
                 }
        }       
        
        component.set('v.newCall',true);
        component.find('calldispositionlwc').newCall();
        
    },
    getValueFromLwc : function(component, event, helper) {
        component.set("v.notes",event.getParam('value'));
        
        if($A.util.isEmpty(component.get('v.notes')))
        {
            
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',false);
                }else{
                    component.set('v.isCDValitated',true);
                }
                
            }
            else
            {
                component.set('v.isCDValitated',false);
            }
            
        }else{
            if(!$A.util.isEmpty(component.get('v.callcategory')))
            {
                if(component.get('v.interventionReq')){
                    component.set('v.isCDValitated',true);
                }
                else{
                    component.set('v.isCDValitated',true);
                }
                
            }
            else
            {
                component.set('v.isCDValitated',false);
                
            }
        }       
        
    },
    getcallcategValueFromLwc : function(component, event, helper) {
        component.set("v.callcategory",event.getParam('value'));
        //alert('LWC to Aura');
        var intervionReq = component.get('v.interventionReq');
        if(intervionReq)
        {
            var notes = component.get('v.notes');
            if($A.util.isEmpty(notes)){
                component.set('v.isCDValitated',false);
            }
            else{ 
                component.set('v.isCDValitated',true);
            }
            
        }else{
            component.set('v.isCDValitated',true);
        }
    },
    validationNotrequired : function(component, event, helper) {
        component.set('v.isCDValitated',true);
        component.set('v.callcategory','');
        component.set('v.callbound','Inbound');
        component.set('v.interventionReq',false);
        component.set('v.notes','');
        component.set('v.newCall',false);
        component.set('v.isStudyInfoModified',false);
    },
    getcallBound : function(component, event, helper) {
        component.set('v.callbound',event.getParam('value'));
    },
    getinterventionchange : function(component, event, helper) {
        var interReq = event.getParam('value');
        var notes = component.get('v.notes');
        component.set('v.interventionReq',interReq);
        if(interReq)
        {
            if(!$A.util.isEmpty(notes))
            {
                if(!$A.util.isEmpty(component.get('v.callcategory')))
                {
                    component.set('v.isCDValitated',true);
                    
                }
                else
                {
                    component.set('v.isCDValitated',false);
                }
                
            }else{ 
                component.set('v.isCDValitated',false);
            }
        }else{
            if($A.util.isEmpty(component.get('v.callcategory')))
            {
                component.set('v.isCDValitated',false);
            }else{ component.set('v.isCDValitated',true);}
            
        }
    },
    updCDobj : function(component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            callbound: component.get('v.callbound'),
            callcategory: component.get('v.callcategory'),
            interventionReq: component.get('v.interventionReq'),
            notes: component.get('v.notes')
        });
        component.set('v.CD', RowItemList);
    }
})