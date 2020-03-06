({
    showPopUpInfo: function (component, event, helper) {
        var enrollment = component.get('v.enrollmentData').enrollment;
        var modal = component.find('infoModal');
        if(modal) modal.showHCPEnrollmentStatusDetail(enrollment);
    },

    doAction: function (component, event, helper) {
        var actionId;
        try{
            actionId = event.currentTarget.id;
        } catch (error) {
            actionId = event.getParam('value');
        }
        var enrollment = component.get('v.enrollmentData').enrollment;
        if (!actionId || !enrollment) {
            communityService.showErrorToast('Error', $A.get('$Label.c.TST_Something_went_wrong'));
            return;
        }
        var parent = component.get('v.parent');
        var comp = parent.find('changeHCPStatusByPIAction');
        comp.execute(enrollment, actionId, parent);
    },

    handleSelect:function(component, event, helper){

    },
})