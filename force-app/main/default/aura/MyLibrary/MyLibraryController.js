({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
    },
    handleSectionSelection: function (component, event, helper) {
        var documentationBtnId = "documentation";
        var supportingMaterialsBtnId = "supporting-materials";
        var btnId = event.currentTarget.id;
        if(btnId === documentationBtnId){
            component.set("v.showDocumentation", true);
        }else if(btnId === supportingMaterialsBtnId) {
            component.set("v.showSupportingMaterials", true);
        }
    }
})