({
    doInit: function (component, event, helper) {
        var isPortalTC = component.get('v.isPortalTC');
        var action;
        var titleCode = component.get('v.titleCode');
        if(titleCode === 'PrivacyPolicy'){
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Privacy_Policy'))
        }else if(titleCode === 'CookiePolicy'){
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Cookie_Policy'))
        }else{
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Terms_And_Conditions'))
        }
        component.find('mainSpinner').show();
        if(isPortalTC){
            communityService.executeAction(component, 'getPortalTcData', null, function (returnValue) {
                component.set("v.tcData", JSON.parse(returnValue));
            }, null, function () {
                component.find('mainSpinner').hide();
            });
        }else{
            var privacyPolicyId = component.get('v.privacyPolicyId');
            if(privacyPolicyId){
                communityService.executeAction(component, 'getTC', {
                    tcId: privacyPolicyId,
                    languageCode: communityService.getUrlParameter('language')
                }, function (returnValue) {
                    component.set("v.tcData", JSON.parse(returnValue));
                }, null, function () {
                    component.find('mainSpinner').hide();
                });
            }else{
                var ctpId = communityService.getUrlParameter('id');
                component.set('v.ctpId', ctpId);
                communityService.executeAction(component, 'getTrialTcData', {
                    ctpId: ctpId
                }, function (returnValue) {
                    component.set("v.tcData", JSON.parse(returnValue));
                }, null, function () {
                    component.find('mainSpinner').hide();
                });
            }
        }
    },

    doAccept: function (component, event, helper) {
        var tcData = component.get('v.tcData');
        var isPortalTC = component.get('v.isPortalTC');
        communityService.executeAction(component, 'acceptTC', {
            tcId: tcData.tc.Id
        }, function (returnValue) {
            communityService.setTCAccepted();
            helper.goBack(component);
            if(!isPortalTC){
                communityService.showSuccessToast('Success',  $A.get('$Label.c.PG_TC_H_Accept_Success') + ' ' + tcData.trial.Study_Code_Name__c  + '.');
            }else{
                $A.get("e.c:EventCommunityInitialized").fire();
            }
        });
    },

    doGoBack: function (component, event, helper) {
        helper.goBack(component);
    }

})