/**
 * Created by Yehor Dobrovolskyi
 */
({
    onClick: function (component, event, helper) {
        if (!component.get('v.isClicked')) {
            component.set('v.isClicked', !component.get('v.isClicked'));
        }
        let trial = component.get('v.trialTDO');
        if (!trial.isEnrollingCTP) {
            communityService.showToast('success', 'success', 'Thank you for your interest in ' + trial.ctp.Study_Code_Name__c + '. We will contact you when the clinical research study begins enrollment.')
        } else {
            let form = component.find('contactModal');
            form.show();
        }
    },

    onClickSend: function (component, event, helper) {
        var form = component.find('contactForm');
        form.checkFields();
        if (form.get('v.isValid')) {
            let participantInfo = component.get('v.participantInfo');
            let ctp = component.get('v.trialTDO').ctp;
            helper.enqueue(component, 'c.createCaseToStudy', {
                participant: participantInfo,
                ctp: ctp,
                isDelegate : communityService.isDelegate()
            })
                .then(function (data) {
                    if (participantInfo.Id) {
                        component.set('v.participant', participantInfo);
                    }
                    console.log(JSON.stringify(component.get('v.participantInfo')));
                    communityService.showToast('success', 'success', 'Thank you for your interest in ' + ctp.Study_Code_Name__c + '.  Someone from the study team will contact you shortly. ');
                    component.find('contactModal').hide();
                }, function (err) {
                    console.error(err);
                    communityService.showToast('error', 'error', 'OPSsssss');
                }).catch(function (err) {
                console.error(err);
            });
            communityService.executeAction(component, 'createTrialNotification', {
                ctpId: trial.ctp.Id
            }, function () {
                communityService.showToast('success', 'success', 'Thank you for your interest in ' + trial.ctp.Study_Code_Name__c + '. We will contact you when the clinical research study begins enrollment.')
            });
        }
    }
});