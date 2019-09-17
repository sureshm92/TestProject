/**
 * Created by Yehor Dobrovolskyi
 */
({
    onClick: function (component, event, helper) {
        component.set('v.isClicked', !component.get('v.isClicked'));
        let trial = component.get('v.trialTDO');
        if (!trial.isEnrollingCTP) {
            communityService.executeAction(component, 'createTrialNotification', {
                ctpId: trial.ctp.Id
            }, function () {
                communityService.showToast('success', 'success', 'Thank you for your interest in ' + trial.ctp.Study_Code_Name__c + '. We will contact you when the clinical research study begins enrollment.')
            });
        }
    }
});