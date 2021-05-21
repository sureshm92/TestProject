({
    handleForgotPassword: function (component, event, helpler) {
        helpler.handleForgotPassword(component, event, helpler);
    },
    setUserName: function (component, event, helpler) {
        alert('setUserName' + event.getParam('usr'));
        component.set('v.usrval', event.getParam('usr'));
        helpler.publishMC(component, event, helpler);
    },
    onKeyUp: function (component, event, helpler) {
        //checks for "enter" key
        if (event.getParam('keyCode') === 13) {
            helpler.handleForgotPassword(component, event, helpler);
        }
    },
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set('v.expid', expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },

    initialize: function (component, event, helper) {
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        var paramLanguage = communityService.getUrlParameter('language');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
        $A.get('e.siteforce:registerQueryEventMap')
            .setParams({ qsToEvent: helper.qsToEventMap })
            .fire();
        var community = window.location.pathname.startsWith('/gsk/')
            ? '/gsk/s/login'
            : window.location.pathname.startsWith('/janssen/')
            ? '/janssen/s/login'
            : '/s/login';
        component.set('v.backPage', community);
    },

    goBack: function (component, event, helper) {
        var community = window.location.pathname.startsWith('/gsk/')
            ? '/gsk/s/login'
            : window.location.pathname.startsWith('/janssen/')
            ? '/janssen/s/login'
            : '/s/login';
        window.location.href = community;
    }
});
