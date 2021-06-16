({
    doInit: function (component, event, helper) {
        let currentCommunityMode = communityService.getCurrentCommunityMode();
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        var paramLanguage = communityService.getUrlParameter('language');
        var RTL;
        if (paramLanguage) {
            RTL = rtl_language.includes(paramLanguage);
            component.set('v.isRTL', RTL);
        } else {
            RTL = component.get('v.isRTL');
        }
        if (currentCommunityMode) {
            component.set('v.userMode', currentCommunityMode.userMode);
        }
        component.set('v.isMobileApp', communityService.isMobileSDK());
        //let elem = document.getElementById('cookiePanel');
        //let rrCookies = communityService.getCookie('RRCookies');
        /*if(elem){
           let bottomLine =  document.getElementsByClassName('rr-bottom-bar-area');
           $A.util.addClass(bottomLine[0],'bottom-line-with-cookie');
           let paddingForCookie = document.getElementsByClassName('rr-body-content');
           $A.util.addClass(paddingForCookie[0],'padding-for-cookie-policy');
        }*/
        let ctpId = communityService.getUrlParameter('id');
        let isPortalTC = ctpId ? false : component.get('v.isPortalTC');

        let titleCode = component.get('v.titleCode');
        if (titleCode === 'PrivacyPolicy') {
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Privacy_Policy'));
            document.title =$A.get('$Label.c.PG_TC_H_Privacy_Policy');
        } else if (titleCode === 'CookiePolicy') {
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Cookie_Policy'));
            document.title = $A.get('$Label.c.PG_TC_H_Cookie_Policy');
        } else {
            component.set('v.title', $A.get('$Label.c.PG_TC_H_Terms_And_Conditions'));
            document.title = $A.get('$Label.c.PG_TC_H_Terms_And_Conditions');
        }
        communityService.executeAction(component, 'getCommunityName', {}, function (returnValue) {
            if (returnValue !== null) {
                if(returnValue == 'GSK Community'){
                    component.set('v.isGsk', true);
                }
            }
        });
        if (communityService.isInitialized()){
            if(communityService.getCurrentCommunityName() == 'GSK Community'){
            component.set('v.isGsk', true);
        	}
        }
        component.find('mainSpinner').show();
        let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
        let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
        if (isPortalTC) {
            if (titleCode === 'CookiePolicy' || titleCode === 'PrivacyPolicy') {
                if(component.get("v.isGsk")){
                    communityService.executeAction(
                        component,
                        'getTC',
                        {
                            code: titleCode,
                            languageCode: communityService.getUrlParameter('language'),
                            useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC
                        },
                        function (returnValue) {
                            let tcData = JSON.parse(returnValue);
                            component.set('v.tcData', tcData);
                            if (RTL) {
                                helper.setRTL(component);
                            }
                            if (tcData.tc) {
                                component.set('v.privacyPolicyId', tcData.tc);
                            }
                        },
                        null,
                        function () {
                            component.find('mainSpinner').hide();
                        }
                    );
                }else{
                    component.find('mainSpinner').hide();
                }
            } else {
                communityService.executeAction(
                    component,
                    'getPortalTcData',
                    {
                        useDefaultCommunity:
                            communityService.getHasIQVIAStudiesPI() && userDefalutTC
                    },
                    function (returnValue) {
                        component.set('v.tcData', JSON.parse(returnValue));
                        if (RTL) {
                            helper.setRTL(component);
                        }
                    },
                    null,
                    function () {
                        component.find('mainSpinner').hide();
                    }
                );
            }
        } else {

            if (titleCode === 'CookiePolicy' || titleCode === 'PrivacyPolicy') {
                    communityService.executeAction(
                        component,
                        'getTC',
                        {
                            code: titleCode,
                            languageCode: communityService.getUrlParameter('language'),
                            useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC
                        },
                        function (returnValue) {
                            let tcData = JSON.parse(returnValue);
                            component.set('v.tcData', tcData);
                            if (RTL) {
                                helper.setRTL(component);
                            }
                            if (tcData.tc) {
                                component.set('v.privacyPolicyId', tcData.tc);
                            }
                        },
                        null,
                        function () {
                            component.find('mainSpinner').hide();
                        }
                    );    
            } else {
                if (!component.get('v.ctpId')) {
                    component.set('v.ctpId', ctpId);
                }
                communityService.executeAction(
                    component,
                    'getTrialTcData',
                    {
                        ctpId: component.get('v.ctpId')
                    },
                    function (returnValue) {
                        component.set('v.tcData', JSON.parse(returnValue));
                        if (RTL) {
                            helper.setRTL(component);
                        }
                    },
                    null,
                    function () {
                        component.find('mainSpinner').hide();
                    }
                );
            }
        }

        helper.hideOkButton(component, event, helper); // @Krishna Mahto - PEH-2450
    },
    doAccept: function (component, event, helper) {
        let tcData = component.get('v.tcData');
        let isPortalTC = component.get('v.isPortalTC');
        communityService.executeAction(
            component,
            'acceptTC',
            {
                tcId: tcData.tc.Id
            },
            function (returnValue) {
                communityService.setTCAccepted();
                helper.goBack(component);
                if (!isPortalTC && tcData.trial != null) {
                    communityService.showSuccessToast(
                        'Success',
                        $A.get('$Label.c.PG_TC_H_Accept_Success') +
                            ' ' +
                            tcData.trial.Study_Code_Name__c +
                            '.'
                    );
                } else {
                    $A.get('e.c:EventCommunityInitialized').fire();
                }
            }
        );
    },

    doGoBack: function (component, event, helper) {
        helper.goBack(component);
    },

    removeClasses: function (component, event, helper) {
        let bottomLine = document.getElementsByClassName('bottom-line-with-cookie');
        $A.util.removeClass(bottomLine[0], 'bottom-line-with-cookie');
        let paddingForCookie = document.getElementsByClassName('padding-for-cookie-policy');
        $A.util.removeClass(paddingForCookie[0], 'padding-for-cookie-policy');
    },
    init: function(component, event, helper) {        
        document.title = $A.get("{!$Label.c.BTN_View_terms_and_conditions_participant}");
    }
});