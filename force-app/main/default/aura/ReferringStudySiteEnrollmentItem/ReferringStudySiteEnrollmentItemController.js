({
    doInit: function (component, event, helper) {
        debugger;
        var enrollmentWrapper = component.get("v.enrollmentWrapper");
        component.set("v.status", enrollmentWrapper.enrollment.Status__c.split(' (')[0]);
    },
    showPopUpInfo: function (component, event, helper) {

        var studySite = component.get("v.studySite");
        if(!studySite) return;

        var modal = component.find('infoModal');
        if(modal) modal.showStudySiteStatusDetail(studySite);
    }
})