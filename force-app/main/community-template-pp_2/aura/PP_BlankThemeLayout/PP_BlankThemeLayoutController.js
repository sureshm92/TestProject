({
    doInit: function (component, event, helper) {
        var language = communityService.getUrlParameter('language');
        if (!language || language === '') {
            language = 'en_US';
        }
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isRTL', rtl_language.includes(language));
    }
});
