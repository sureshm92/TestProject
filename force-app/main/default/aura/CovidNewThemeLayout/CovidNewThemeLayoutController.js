({
    doInit : function(component, event, helper){
        component.set('v.isInitialized', true);
    },
    top: function(component, event, helper){
        window.scrollTo(300, 500);
    },
    
    howDoes: function(component, event, helper){
        window.scrollTo(0, 0);
    },
    
    navigate : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
           'url': 'http://plasma.c19trials.com/'
         });
         urlEvent.fire();
    }     
})