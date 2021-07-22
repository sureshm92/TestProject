/**
 * Created by  Leonid Bartenev
 */
({
    doInit: function(component, event, helper) {
        let rrCookies = communityService.getCookie('RRCookies');
        let paramLanguage = communityService.getUrlParameter('lanCode');
        let isMobileApp = communityService.isMobileSDK();
        if (!rrCookies) {
            communityService.executeAction(component, 'getCommunityUrl', {}, function(rValue) {
                console.log(rValue);
                let communityPrefix = rValue;
                let check = communityPrefix.includes('Janssen Community');
                let infoText =
                    check == true
                        ? $A.get('$Label.c.Cookies_Info_Text_Janssen')
                        : $A.get('$Label.c.Cookies_Info_Text');
                let linkCookies = $A.get('$Label.c.Link_Cookies');
                let communityUrl = window.location.href;
                let linkPPUrl = '';
                let linkCP = '';
                let linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy');
                let linkIAB = $A.get('$Label.c.Link_Interactive_Advertising_Bureau');
                let urlIAB = $A.get('$Label.c.URL_Interactive_Advertising_Bureau');
                if (check) {
                    linkPPUrl =
                        '<a class="ci-link" href="/janssen/s/privacy-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                    linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy_Janssen');
                    linkCP =
                        '<a class="ci-link" href="/janssen/s/cookie-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                } else if (communityUrl.includes('gsk')) {
                    linkPPUrl =
                        '<a class="ci-link" href="/gsk/s/privacy-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                    linkCP =
                        '<a class="ci-link" href="/gsk/s/cookie-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                } else if (communityUrl.includes('Covid19')) {
                    linkPPUrl =
                        '<a class="ci-link" href="Covid19/s/privacy-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                    linkCP =
                        '<a class="ci-link" href="Covid19/s/cookie-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                } else {
                    linkPPUrl =
                        '<a class="ci-link" href="/s/privacy-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                    linkCP =
                        '<a class="ci-link" href="/s/cookie-policy?lanCode=' +
                        paramLanguage +
                        '"' +
                        (!isMobileApp && communityUrl.includes('login') ? 'target="_blank"' : '') +
                        '>';
                }
                if (
                    communityPrefix.includes('Janssen Community') ||
                    communityPrefix.includes('IQVIA Referral Hub')
                ) {
                    infoText = infoText.replace('##cookiesURL', $A.get('$Label.c.Link_Cookies'));
                } else {
                    infoText = infoText.replace('##cookiesURL', linkCP + linkCookies + '</a>');
                }
                infoText = infoText.replace('##privacyPolicyURL', linkPPUrl + linkPP + '</a>');
                infoText = infoText.replace(
                    '##interactiveAdvertisingBureauURL',
                    '<a class="ci-link" href="' + urlIAB + '">' + linkIAB + '</a>'
                );
                component.set('v.resultInfoText', infoText);
                component.set('v.visible', true);
                component.cookiesOff = $A.getCallback(function() {
                    communityService.setCookie('RRCookies', 'agreed');
                    component.set('v.visible', false);
                    document.body.removeEventListener('click', component.cookiesOff, false);
                });
                document.body.addEventListener('click', component.cookiesOff, false);
                setTimeout(
                    $A.getCallback(function() {
                        component.cookiesOff();
                    }),
                    20000
                );
            });
        }
    },

    doCloseCookiesInfo: function(component) {
        communityService.setCookie('RRCookies', 'agreed');
        let appEvent = $A.get('e.c:TCCookieClassesRemove');
        appEvent.fire();
        component.set('v.visible', false);
    }
});
