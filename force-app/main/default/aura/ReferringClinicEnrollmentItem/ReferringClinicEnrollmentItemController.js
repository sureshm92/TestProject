({
    showPopUpInfo: function (component, event, helper) {
        var enrollment = component.get('v.enrollmentData').enrollment;
        var modal = component.find('infoModal');
        if (modal) modal.showHCPEnrollmentStatusDetail(enrollment);
    },

    doAction: function (component, event, helper) {
        var actionId;
        try {
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
        var hcpNameDetails = component.get('v.hcpContactPartName');
        var hcpName;
        if(hcpNameDetails !=undefined && hcpNameDetails !=null){
            if(hcpNameDetails.First_Name__c!=undefined && hcpNameDetails.First_Name__c !=null){
                hcpName = hcpName==undefined?hcpNameDetails.First_Name__c : hcpName + ' ' + hcpNameDetails.First_Name__c;
            }
            if(hcpNameDetails.Middle_Name__c!=undefined && hcpNameDetails.Middle_Name__c !=null){
                hcpName = hcpName==undefined?hcpNameDetails.Middle_Name__c : hcpName + ' ' + hcpNameDetails.Middle_Name__c;
            }
            if(hcpNameDetails.Last_Name__c!=undefined && hcpNameDetails.Last_Name__c !=null){
                hcpName = hcpName==undefined?hcpNameDetails.Last_Name__c : hcpName + ' ' + hcpNameDetails.Last_Name__c;
            }
            if(hcpNameDetails.Suffix__c!=undefined && hcpNameDetails !=null){
                hcpName = hcpName==undefined?hcpNameDetails.Suffix__c : hcpName + ' ' + hcpNameDetails.Suffix__c;
            }
        }
        comp.execute(enrollment, actionId, parent, hcpName);
    },

    handleSelect: function (component, event, helper) {}
});
