({
    doShow: function (component, event) {
        var params = event.getParam('arguments');
        component.set('v.targetEmail', '');
        component.set('v.hcpe', params.hcpe);
        component.find('shareModal').show();
    },

    doHide: function (component) {
        component.find('shareModal').hide();
    },

    doShare: function (component, event, helper) {
        var email = component.get('v.targetEmail');
        if(!communityService.isValidEmail(email)){
            communityService.showErrorToast('', $A.get("$Label.c.TST_Invalid_email_address"));
            return;
        }

        var spinner = component.find('spinner');
        spinner.show();
        var hcpe = component.get('v.hcpe');
        communityService.executeAction(component, 'sendEmail', {
            hcpeId: hcpe.Id,
            hcpContactId: hcpe.HCP_Contact__c,
            email: email
        }, function (returnValue) {
            var parent = component.get('v.parent');
            if(parent) parent.refresh();
            communityService.showSuccessToast('success', $A.get("$Label.c.TST_Email_was_successfully_sent"));
        }, null, function () {
            component.find('shareModal').hide();
            spinner.hide();
        });
    },

    doCancel: function (component, event, helper) {
        component.find('shareModal').hide();
    }
})