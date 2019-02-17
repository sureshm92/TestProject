({
    doInit: function (component, event, helper) {
        if (!document.isInitialized()) return;
        if(document.communityMode !== "PI") document.navigateToPage("");
        helper.getReferredClinics(component);
    },
    showPendingPhysicans: function (component, event, helper) {
        $A.util.toggleClass(event.currentTarget, "active");

        if($A.util.hasClass(event.currentTarget, "active")){
            helper.showPendingPhysicians(component);
        } else {
            helper.showAllPhysicians(component);
        }
    }
})