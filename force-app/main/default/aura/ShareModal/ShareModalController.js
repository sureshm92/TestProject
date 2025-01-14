({
    doShow: function (component, event) {
        var params = event.getParam('arguments');
        component.set('v.targetEmail', '');
        component.set('v.whatId', params.whatId);
        component.set('v.fromId', params.fromId);
        component.find('shareModal').show();
    },

    doHide: function (component) {
        component.find('shareModal').hide();
    },

    doShare: function (component, event, helper) {
        var email = component.get('v.targetEmail');
        if (!communityService.isValidEmail(email)) {
            communityService.showErrorToast('', $A.get('$Label.c.TST_Invalid_email_address'));
            return;
        }
        var spinner = component.find('spinner');
        spinner.show();

        var whatId = component.get('v.whatId');
        var fromId = component.get('v.fromId');
        let emailType = component.get('v.emailType');
        communityService.executeAction(
            component,
            'sendEmail',
            {
                whatId: whatId,
                fromId: fromId,
                email: email,
                emailType: emailType
            },
            function (returnValue) {
                var parent = component.get('v.parent');
                if (component.get('v.needRefresh') === true) {
                    if (parent) parent.refresh();
                }

                communityService.showSuccessToast(
                    'success',
                    $A.get('$Label.c.TST_Email_was_successfully_sent')
                );
            },
            null,
            function () {
                component.find('shareModal').hide();
                spinner.hide();
            }
        );
    },

    doCancel: function (component, event, helper) {
        component.find('shareModal').hide();
    }
});
