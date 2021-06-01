({
    doInit: function (component, event, helper) {
        let rtl_language = $A.get('$Label.c.RTL_Languages');
        let paramLanguage = communityService.getUrlParameter('language');
        let communityType = component.get('v.communityType');
        let isMobileApp = communityService.isMobileSDK();
        let windowUrl = window.location.href;
        let bodyText =
            communityType !== 'Janssen'
                ? $A.get('$Label.c.Cookies_Info_Text')
                : $A.get('$Label.c.Cookies_Info_Text_Janssen');
        let privacyPolicyLinkText =
            communityType !== 'Janssen'
                ? $A.get('$Label.c.Footer_Link_Privacy_Policy')
                : $A.get('$Label.c.Footer_Link_Privacy_Policy_Janssen');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
        if (communityService.isMobileSDK() || communityService.isMobileOS()) {
            component.set('v.isMobile', true);
        }

        bodyText = bodyText
            .replace('##cookiesURL', '')
            .replace(
                '##privacyPolicyURL',
                '<a class="ci-link" href="/s/privacy-policy?lanCode=' +
                    paramLanguage +
                    '"' +
                    (!isMobileApp && windowUrl.includes('login') ? 'target="_blank"' : '') +
                    '>' +
                    privacyPolicyLinkText +
                    '</a>'
            );
        component.set('v.cookieText', bodyText);
    }
});
