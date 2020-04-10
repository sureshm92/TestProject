/**
 * Created by Yehor Dobrovolskyi
 */
({
    onClick: function (component, event, helper) {
        component.find('mainSpinner').show();
        let trial = component.get('v.trialTDO');
        if (!trial.isEnrollingCTP) {
            communityService.executeAction(component, 'createSubscribeConnectionEnroll', {
                ctpId: trial.ctp.Id
            }, function () {
                component.find('mainSpinner').hide();
                let trialTDO = component.get('v.trialTDO');
                trialTDO.relatedNotificationExists = true;
                component.set('v.trialTDO', trialTDO);
                helper.checkClick(component);
                communityService.showSuccessToast(
                    'success',
                    String.format($A.get('$Label.c.TrialSearch_Toast_Alert_Me_When_Trial_Start'), trial.ctp.Study_Code_Name__c),
                    500);
            });
        } else if (!trial.ctp.Link_to_ePR_Campaign__c) {
            component.find('mainSpinner').hide();
            helper.checkClick(component);
            component.set('v.showModal', true);
            let form = component.find('contactModal');
            form.set('v.closeCallback', $A.getCallback(function () {
                if (!component.get('v.isSecondClicked')) {
                    component.set('v.isClicked', false);
                }
            }));
            form.show();
        } else {
            component.find('mainSpinner').hide();
            let urlEpr = trial.ctp.Link_to_ePR_Campaign__c;
            if (!urlEpr.match('https?:\/\/')) {
                urlEpr = 'http://' + urlEpr;
            }
            window.open(urlEpr);
        }
    },

    onClickSend: function (component, event, helper) {
        var form = component.find('contactForm');
        form.checkFields();
        if (form.get('v.isValid')) {
            let participantInfo = component.get('v.participantInfo');
            let ctp = component.get('v.trialTDO').ctp;
            component.find('mainSpinner').show();
            component.find('contactModal').hide();
            communityService.executeAction(component, 'createCaseToStudy', {
                participant: participantInfo,
                ctp: ctp,
                isDelegate: communityService.isDelegate()
            }, function () {
                if (participantInfo.Id) component.set('v.participant', participantInfo);
                communityService.showSuccessToast(
                    'success',
                    String.format($A.get('$Label.c.TrialSearch_Toast_Contact_The_Study'), ctp.Study_Code_Name__c),
                    500);
            }, null, function () {
                component.find('mainSpinner').hide();
            });
        }
    },
});