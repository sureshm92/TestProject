/**
 * Created by Alexey Moseev.
 */
({
    doinit:function(component, event, helper)
    {
        var piData = component.get('v.piData');
        component.set('v.communityTemplate', communityService.getCurrentCommunityTemplateName());
        component.set('v.delegatePIPicklistvalues',piData.delegatePIsPicklist);
        component.set('v.piCTPPicklist', piData.piCTPPicklist);
        component.set('v.currentPi', piData.selectedPi); 
        component.set('v.currentStudy', piData.selectedCTP);  
    },
    
    /* refreshDataOnStudyChange:function(component, event, helper)
    {
       // var piData = component.get('v.piData');
        //component.set('v.piData', piData);  
                

    },

    refreshDataOnPiChange:function(component, event, helper)
    {
           

    }*/
    
    refreshDataOnStudyChange:function(component, event, helper){
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        piData.selectedCTP = component.get('v.currentStudy');
        var spinner = component.find('mainSpinner');
        spinner.show();
        helper.callServerMethod1(component, 'getInitData', communityService.getUserMode(), communityService.getCurrentCommunityTemplateName(), communityService.getDelegateId(), piData.selectedPi, null, 'PIChange',helper);
     	//var currentData = component.get('v.piData');
       //	component.set('v.currentStudy', component.get('v.currentStudy')); 
       		
    },
    
    refreshDataOnPiChange:function(component, event, helper){
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        piData.selectedCTP = component.get('v.currentStudy');
        var spinner = component.find('mainSpinner');
        spinner.show(); 
        helper.callServerMethod(component, 'getInitData', communityService.getUserMode(), communityService.getCurrentCommunityTemplateName(), communityService.getDelegateId(), piData.selectedPi,  null, 'PIChange',helper);
      //  component.set('v.currentPi', component.get('v.currentPi')); 

    }
    
})