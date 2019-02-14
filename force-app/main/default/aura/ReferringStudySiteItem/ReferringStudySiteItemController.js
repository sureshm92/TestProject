({
    doInit: function (component, event, helper) {
        var status = component.get("v.workspaceWrapper").studySite.Override_PI_Referral_Status__c;
        component.set("v.status", status.split(' (')[0]);
    },
    showPopUpInfo: function (component, event, helper) {

        var studySite = component.get("v.workspaceWrapper").studySite;
        if(!studySite) return;

        var modal = component.find('infoModal');
        if(modal) modal.showStudySiteStatusDetail(studySite);
    }
})