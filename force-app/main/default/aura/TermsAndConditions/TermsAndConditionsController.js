({
    doInit: function (component, event, helper) {
        let currentCommunityMode = communityService.getCurrentCommunityMode();
        if(currentCommunityMode) component.set('v.userMode', currentCommunityMode.userMode);
        var elem = document.getElementById('cookiePanel');
        //var rrCookies = communityService.getCookie('RRCookies');
        if(elem){
           var bottomLine =  document.getElementsByClassName('rr-bottom-bar-area');
           $A.util.addClass(bottomLine[0],'bottom-line-with-cookie');
           var paddingForCookie = document.getElementsByClassName('rr-body-content');
           $A.util.addClass(paddingForCookie[0],'padding-for-cookie-policy');
        }
        var titleCode = component.get('v.titleCode');
        let ctpId = communityService.getUrlParameter('id');
        var isPortalTC;
        if(ctpId) {
            isPortalTC = false;
        } else {
            isPortalTC = component.get('v.isPortalTC');
        }

        if(titleCode === 'PrivacyPolicy'){
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Privacy_Policy'));
        }else if(titleCode === 'CookiePolicy'){
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Cookie_Policy'));
        }else{
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Terms_And_Conditions'));
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
                if(!component.get('v.ctpId')) {
                    component.set('v.ctpId', ctpId);
                }
                communityService.executeAction(component, 'getTrialTcData', {
                    ctpId: component.get('v.ctpId')
                }, function (returnValue) {
                    component.set("v.tcData", JSON.parse(returnValue));
                }, null, function () {
                    component.find('mainSpinner').hide();
                });
            }
        }
        helper.hideOkButton(component, event, helper); // @Krishna Mahto - PEH-2450 
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
    },

    removeClasses: function(component, event, helper){
            var bottomLine =  document.getElementsByClassName('bottom-line-with-cookie');
            $A.util.removeClass(bottomLine[0],'bottom-line-with-cookie');
            var paddingForCookie = document.getElementsByClassName('padding-for-cookie-policy');
            $A.util.removeClass(paddingForCookie[0],'padding-for-cookie-policy');
    },

})