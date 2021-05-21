({
    doInit: function (component, event, helper) {
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        var paramLanguage = communityService.getUrlParameter('language');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
    }
});
