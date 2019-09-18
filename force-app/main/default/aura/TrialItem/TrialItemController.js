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
            // component.set("v.showModal", true);
            let form = component.find('contactModal');
            form.show();
            // form.doInit();
        }
    },

    onClickSend: function (component, event, helper) {
        var form = component.find('contactForm');
        form.checkFields();
        if (form.get('v.isValid')) {
            let participantInfo = component.get('v.participantInfo');
            helper.enqueue(component, 'c.createCaseToStudy', {
                'participant': participantInfo,
                isDelegate : communityService.isDelegate()
            })
                .then(function (data) {
                    if (participantInfo.Id) {
                        component.set('v.participant', participantInfo);
                    }
                    console.log(JSON.stringify(component.get('v.participantInfo')));
                    let ctp = component.get('v.trialTDO').ctp;
                    communityService.showToast('success', 'success', 'Thank you for your interest in ' + ctp.Study_Code_Name__c + '.  Someone from the study team will contact you shortly. ');
                    // component.set("v.showModal", false);
                    component.find('contactModal').hide();
                }, function (err) {
                    console.error(err);
                    communityService.showToast('error', 'error', 'OPSsssss');
                }).catch(function (err) {
                console.error(err);
                // component.find('mainSpinner').hide();
            });
        }
    }
});