({
    doInit : function (component, event, helper) {
        component.find('reminderModal').show();
    },
    
    doCancel : function(component, event, helper) {
        component.find('reminderModal').hide();
    },
    
    doSave : function(component, event, helper){
        
    },

    doIgnore : function(component, event, helper){
        
    },

    doMarkComplete : function(component, event, helper){
        
    }
})