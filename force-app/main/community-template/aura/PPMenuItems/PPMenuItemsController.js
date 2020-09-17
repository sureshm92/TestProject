/**
 * Created by Olga Skrynnikova on 6/10/2020.
 */

({
    doInit: function(component,event,helper){
       //helper.toggleHelper(component, event);
    },
    doOnClick: function (component, event) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        onclickEvent.fire();
    },
    display : function(component, event, helper) { 
        var dataVal = event.currentTarget.dataset.id;       
        component.set("v.hovertext",dataVal);
        var cmpTarget = component.find('tooltip');
      if(dataVal=='Delegates'){
          if(component.get("v.isRTL")){
            $A.util.addClass(cmpTarget, 'tooltipRTL');
            $A.util.removeClass(cmpTarget, 'tooltip');
          }else{
            $A.util.addClass(cmpTarget, 'tooltip');
            $A.util.removeClass(cmpTarget, 'tooltipRTL');
          }
            $A.util.addClass(cmpTarget,'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget, 'tooltipASRTL');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
            $A.util.removeClass(cmpTarget,'slds-nubbin--top');
            $A.util.removeClass(cmpTarget,'tooltipNotActive');
        }
       else if(dataVal=='Account Settings'){
        if(component.get("v.isRTL")){
            $A.util.addClass(cmpTarget, 'tooltipASRTL');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
          }else{
            $A.util.addClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget, 'tooltipASRTL');
          }
           $A.util.addClass(cmpTarget,'slds-nubbin--bottom');
           $A.util.removeClass(cmpTarget, 'tooltip');
           $A.util.removeClass(cmpTarget, 'tooltipRTL');
           $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
           $A.util.removeClass(cmpTarget,'slds-nubbin--top');
           $A.util.removeClass(cmpTarget,'tooltipNotActive');
        }     
        else if(dataVal=='No active studies'){
            $A.util.addClass(cmpTarget, 'tooltipNotActive');
        }
        else{
            $A.util.addClass(cmpTarget, 'tooltipSubTitle'); 
            $A.util.addClass(cmpTarget,'slds-nubbin--top');
            $A.util.removeClass(cmpTarget, 'tooltip');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget,'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget,'tooltipNotActive');
        }
        
        $A.util.addClass(cmpTarget, 'tooltip');
        if(dataVal!='No active studies'){
        	helper.toggleHelper(component, event);
        }        
    },    
    displayOut : function(component, event, helper) {
       helper.toggleHelper(component, event);
    }
});