/**
 * Created by Igor Malyuta on 25.03.2019.
 */
({
    doInit : function (component, event, helper) {
        var infoText = $A.get('$Label.c.PG_PST_L_Delegates_Designed_Text');

        communityService.executeAction(component, 'getYourPatientFirstName', {},
            function (returnValue) {
                infoText = infoText.replace('##PatientFirstName', returnValue);
                infoText = infoText.replace('##PatientFirstName', returnValue);
                component.set('v.infoText', infoText);
            });
    },

    onclickWithdraw : function (component, event, helper) {
        helper.showModalChangeValue(component);
    },

    doRemoveHimself : function (component, event, helper) {
        communityService.executeAction(component, 'withdrawDelegate', {
            delegate : JSON.stringify(component.get('v.contact'))
        }, function () {
            helper.showModalChangeValue(component);
            communityService.showSuccessToast(null, $A.get('$Label.c.PG_PST_L_Delegates_You_Withdraw_Succ'));
        });
        helper.doLogOut(component);
    }
})