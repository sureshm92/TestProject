/**
 * Created by Andrii Kryvolap
 */
({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    navigateToContact: function (component, event, helper) {
        var contactId = event.currentTarget.dataset.contactid;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Contact',
                recordId: contactId
            },
        };
        component.find('navLink').navigate(pageRef);
    },
    doInviteStaffMember: function (component, event, helper) {
        let contactId = event.target.dataset.contactId;
        component.find('spinner').show();
        communityService.executeAction(component, 'inviteStaffMember', {
            contactId: contactId,
            ssId: component.get('v.recordId')
        }, function (initData) {
            component.find('spinner').hide();
            communityService.showToast("success", "success", $A.get("$Label.c.TST_SST_Success"));
            setTimeout($A.getCallback(function () {
                helper.doInit(component, event, helper);
            }), 200);
        }, function () {
            communityService.showToast("error", "error", $A.get("$Label.c.TST_SST_Error"));
        });
    }
})