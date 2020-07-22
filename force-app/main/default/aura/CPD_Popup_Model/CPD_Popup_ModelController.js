({
    openModel: function(component, event, helper) {
       component.set("v.isModalOpen", true);
    },
   
    closeModel: function(component, event, helper) {
       component.set("v.isModalOpen", false);
    },
   
    submitDetails: function(component, event, helper) {
       component.set("v.isModalOpen", false);
    },
 })