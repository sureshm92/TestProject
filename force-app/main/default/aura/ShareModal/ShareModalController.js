({
    doShow: function (component, event) {
        var params = event.getParam('arguments');
        component.set('v.targetEmail', '');
        component.set('v.trial', params.trial);
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

        //Forming params for sendEmail
        var trial = component.get('v.trial');
        var id;
        var contactId;
        var userMode = communityService.getUserMode();
        if(userMode === 'HCP') {
            contactId = trial.HCP_Contact__c;
        }
        else if(userMode === 'Participant') {
            id = null;//Messaging.SingleEmailMessage.setWhatId() need related obj
            contactId = null;
        }
        communityService.executeAction(component, 'sendEmail', {
            hcpeId: id,
            hcpContactId: contactId,
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