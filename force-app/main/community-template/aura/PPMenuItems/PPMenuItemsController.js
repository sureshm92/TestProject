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
            $A.util.addClass(cmpTarget, 'tooltip');
            $A.util.addClass(cmpTarget,'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
            $A.util.removeClass(cmpTarget,'slds-nubbin--top');
        }
       else if(dataVal=='Account Settings'){
           $A.util.addClass(cmpTarget, 'tooltipAS');
           $A.util.addClass(cmpTarget,'slds-nubbin--bottom');
           $A.util.removeClass(cmpTarget, 'tooltip');
           $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
           $A.util.removeClass(cmpTarget,'slds-nubbin--top');
        }
        else{
            $A.util.addClass(cmpTarget, 'tooltipSubTitle'); 
            $A.util.addClass(cmpTarget,'slds-nubbin--top');
            $A.util.removeClass(cmpTarget, 'tooltip');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget,'slds-nubbin--bottom');	
        }
        helper.toggleHelper(component, event);
    },    
    displayOut : function(component, event, helper) {
       helper.toggleHelper(component, event);
    }
});