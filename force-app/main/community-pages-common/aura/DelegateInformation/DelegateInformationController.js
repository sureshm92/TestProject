/**
 * Created by Igor Malyuta on 25.03.2019.
 */
({
    doInit: function (component, event, helper) {
        var infoText = $A.get('$Label.c.PG_PST_L_Delegates_Designed_Text');
        var delegateInfoHeader = $A.get('$Label.c.PP_Delegate_Header');
        var withdrawInfoHeader = $A.get('$Label.c.PP_Withdraw_Delegate');
        communityService.executeAction(component, 'getYourPatientFirstName', null, function (
            returnValue
        ) {
            infoText = infoText.replace('##PatientFirstName', returnValue);
            delegateInfoHeader = delegateInfoHeader.replace('##PatientFirstName', returnValue);
            withdrawInfoHeader = withdrawInfoHeader.replace('##PatientFirstName', returnValue);
            component.set('v.infoText', infoText);
            component.set('v.delegateInfoHeader', delegateInfoHeader);
            component.set('v.withdrawInfoHeader', withdrawInfoHeader);
        });
    },

    onClickWithdraw: function (component, event, helper) {
        var messageText = $A.get('$Label.c.PG_PST_L_Delegates_Remove_Himself');
        var titleText = $A.get('$Label.c.PG_PST_L_Delegates_Remove_Himself_Header');
        var contact = component.get('v.contact');
        var actionRemoveDelegate = component.get('v.parentComponent').find('actionRemoveDelegate');
        actionRemoveDelegate.execute(messageText, titleText, function () {
            communityService.executeAction(
                component,
                'withdrawDelegate',
                {
                    contactId: contact.Id,
                    removeHimself: true
                },
                function () {
                    communityService.showSuccessToast(
                        null,
                        $A.get('$Label.c.PG_PST_L_Delegates_You_Withdraw_Succ')
                    );
                }
            );
            helper.doLogOut(component);
        });
    }
});
