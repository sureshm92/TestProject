/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        let rrCookies = communityService.getCookie('RRCookies');
        if (!rrCookies) {
            let infoText = (check == true? $A.get('$Label.c.Cookies_Info_Text_Janssen') : $A.get('$Label.c.Cookies_Info_Text'));
            let linkCookies = $A.get('$Label.c.Link_Cookies');
            let communityPrefix = communityService.getCommunityURLPathPrefix();
            let check = communityPrefix.includes('janssen');
            let linkPPUrl;
            let linkCP;
            let linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy');
            let linkIAB = $A.get('$Label.c.Link_Interactive_Advertising_Bureau');
            let urlIAB = $A.get('$Label.c.URL_Interactive_Advertising_Bureau');
            if (check) {
                linkPPUrl = '<a class="ci-link" href="/janssen/s/privacy-policy">';
                linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy_Janssen');
                linkCP = '<a class="ci-link" href="/janssen/s/cookie-policy">';
            }
            else if(communityPrefix.includes('gsk')){
                linkPPUrl = '<a class="ci-link" href="/gsk/s/privacy-policy">';
                linkCP = '<a class="ci-link" href="/gsk/s/cookie-policy">';
            } 
            else {
                linkPPUrl = '<a class="ci-link" href="/s/privacy-policy">';
                linkCP = '<a class="ci-link" href="/s/cookie-policy">';
            }
            infoText = infoText.replace('##cookiesURL', linkCP + linkCookies + '</a>');
            infoText = infoText.replace('##privacyPolicyURL', linkPPUrl + linkPP + '</a>');
            infoText = infoText.replace('##interactiveAdvertisingBureauURL', '<a class="ci-link" href="' + urlIAB + '">' + linkIAB + '</a>');
            component.set('v.resultInfoText', infoText);
            component.set('v.visible', true);
            component.cookiesOff = $A.getCallback(function () {
                communityService.setCookie('RRCookies', 'agreed');
                component.set('v.visible', false);
                document.body.removeEventListener('click', component.cookiesOff, false);
            });
            document.body.addEventListener('click', component.cookiesOff, false);
            setTimeout($A.getCallback(function () {
                component.cookiesOff();
            }), 10000);
        }

    },

    doCloseCookiesInfo: function (component) {
        communityService.setCookie('RRCookies', 'agreed');
        let appEvent = $A.get("e.c:TCCookieClassesRemove");
        appEvent.fire();
        component.set('v.visible', false);
    }
})