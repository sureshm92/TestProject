/**
 * Created by Olga Skrynnikova on 1/17/2020.
 */

 ({
    doInit: function (component, event, helper) {
      helper.init(component, event, helper) ;
    },
   
    getValueFromLwc : function(component, event, helper) {
        component.set('v.showLWC',false);
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1500);   
        }   

    
});