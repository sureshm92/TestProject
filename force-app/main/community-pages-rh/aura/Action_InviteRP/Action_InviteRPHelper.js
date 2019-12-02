/**
 * Created by Kryvolap on 13.08.2019.
 */
({
    clearInviteFields: function (component, event, helper) {
        component.set("v.firstName", '');
        component.set("v.lastName", '');
        //component.set("v.clinicName", '');
        component.set("v.phone", '');
        component.set("v.emailS", '');
        component.set("v.studySiteId", '');
        component.set("v.hcpContactId", '');
        component.set("v.isDuplicate", false);
        var studySitesForInvitation = component.get('v.studySitesForInvitation');
        for(var i = 0; i< studySitesForInvitation.length; i++){
            studySitesForInvitation[i].selected = false;
        }
        component.set("v.studySitesForInvitation", studySitesForInvitation);

    }
})