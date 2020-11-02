/**
 * Created by Leonid Bartenev
 */
({
    initialize: function (component, event, helper) {
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        var paramLanguage = communityService.getUrlParameter('language');
        component.set('v.UserLanguage', paramLanguage);
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
        component.set('v.isMobileApp', communityService.isMobileSDK());
        $A.get('e.siteforce:registerQueryEventMap')
            .setParams({ qsToEvent: helper.qsToEventMap })
            .fire();
        $A.get('e.siteforce:registerQueryEventMap')
            .setParams({ qsToEvent: helper.qsToEventMap2 })
            .fire();
        component.set(
            'v.isUsernamePasswordEnabled',
            helper.getIsUsernamePasswordEnabled(component, event, helper)
        );
        component.set(
            'v.isSelfRegistrationEnabled',
            helper.getIsSelfRegistrationEnabled(component, event, helper)
        );
        // component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set(
            'v.communitySelfRegisterUrl',
            helper.getCommunitySelfRegisterUrl(component, event, helper)
        );
        communityService.executeAction(component, 'getCommunityName', {}, function (returnValue) {
            if (returnValue !== null) {
                if (returnValue === 'IQVIA Referral Hub') {
                    component.set('v.isGSKCommunity', false);
                } else if (returnValue === 'GSK Community') {
                    component.set('v.isGSKCommunity', true);
                } else if (returnValue === 'Janssen Community') {
                    component.set('v.isJanssen', true);
                }
                communityService.executeAction(
                    component,
                    'getCommunityURL',
                    {
                        communityName: returnValue
                    },
                    function (urlValue) {
                        component.set('v.urlCommunity', urlValue);
                    }
                );
            }
        });

        if (navigator.userAgent.match(/Trident/)) component.set('v.ieClass', 'ie-login-rows');
    },

    resetUrl: function (component, event, helper) {
        component.set(
            'v.communityForgotPasswordUrl',
            helper.getCommunityForgotPasswordUrl(component, event, helper)
        );
    },

    handleLogin: function (component, event, helpler) {
        helpler.handleLogin(component, event, helpler);
    },

    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set('v.startUrl', startUrl);
        }
    },

    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set('v.expid', expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },

    onKeyUp: function (component, event, helpler) {
        var pid = event.target.id;
        if (pid == 'username') {
            //checks for "enter" key
            if (event.which == 13) {
                helpler.handleLogin(component, event, helpler);
            }
        }

        if (pid == 'password') {
            if (event.which == 13) {
                helpler.handleLogin(component, event, helpler);
            }
        }
    },

    navigateToForgotPassword: function (cmp, event, helper) {
        var forgotPwdUrl = cmp.get('v.communityForgotPasswordUrl');
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get('v.forgotPasswordUrl');
        }
        var attributes = { url: forgotPwdUrl };
        $A.get('e.force:navigateToURL').setParams(attributes).fire();
    },

    navigateToSelfRegister: function (cmp, event, helper) {
        var selrRegUrl = cmp.get('v.communitySelfRegisterUrl');
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get('v.selfRegisterUrl');
        }

        var attributes = { url: selrRegUrl };
        $A.get('e.force:navigateToURL').setParams(attributes).fire();
    },

    togglePassword: function (component, event, helper) {
        if (component.get('v.showpassword')) {
            component.set('v.showpassword', false);
        } else {
            component.set('v.showpassword', true);
        }
    },
    openModel: function (component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set('v.isOpen', true);
    },

    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "false"
        component.set('v.isOpen', false);
    },

    openPrivacyPolicy: function (component, event, helper) {
        privacyPolicyURL =
            component.get('v.urlCommunity') +
            '/s/privacy-policy?lanCode=' +
            component.get('v.UserLanguage');
        window.open(privacyPolicyURL, '_blank');
    }
});
