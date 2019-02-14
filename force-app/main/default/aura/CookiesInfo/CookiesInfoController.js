/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        var rrCookies = communityService.getCookie('RRCookies');
        if(!rrCookies){
            var infoText = $A.get('$Label.c.Cookies_Info_Text');
            var linkCookies = $A.get('$Label.c.Link_Cookies');
            var urlCookies = $A.get('$Label.c.URL_Cookies');
            var linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy');
            var linkIAB = $A.get('$Label.c.Link_Interactive_Advertising_Bureau');
            var urlIAB = $A.get('$Label.c.URL_Interactive_Advertising_Bureau')
            infoText = infoText.replace('##cookiesURL', '<a class="ci-link" href="/s/cookie-policy">' + linkCookies + '</a>');
            infoText = infoText.replace('##privacyPolicyURL', '<a class="ci-link" href="/s/privacy-policy">' + linkPP +'</a>');
            infoText = infoText.replace('##interactiveAdvertisingBureauURL', '<a class="ci-link" href="' + urlIAB +'">' + linkIAB + '</a>');
            component.set('v.resultInfoText', infoText);
            component.set('v.visible', true);
        }
    },

    doCloseCookiesInfo: function (component) {
        communityService.setCookie('RRCookies', 'agreed');
        component.set('v.visible', false);
    }

})