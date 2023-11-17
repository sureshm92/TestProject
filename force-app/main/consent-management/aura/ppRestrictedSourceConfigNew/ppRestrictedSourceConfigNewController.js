({
    doInit: function (component, event, helper) {
        helper.init(component, event, helper)  
    },
    
    getValueFromLwc : function(component, event, helper) {
        component.set('v.showLWC',false);
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1500);   
        }   
    });