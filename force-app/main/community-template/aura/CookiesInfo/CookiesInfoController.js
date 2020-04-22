/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        let rrCookies = communityService.getCookie('RRCookies');
        if(!rrCookies){
            let infoText = $A.get('$Label.c.Cookies_Info_Text');
            let linkCookies = $A.get('$Label.c.Link_Cookies');

            let linkPP = $A.get('$Label.c.Footer_Link_Privacy_Policy');
            let linkIAB = $A.get('$Label.c.Link_Interactive_Advertising_Bureau');
            let urlIAB = $A.get('$Label.c.URL_Interactive_Advertising_Bureau')
            infoText = infoText.replace('##cookiesURL', '<a class="ci-link" href="/s/cookie-policy">' + linkCookies + '</a>');
            infoText = infoText.replace('##privacyPolicyURL', '<a class="ci-link" href="/s/privacy-policy">' + linkPP +'</a>');
            infoText = infoText.replace('##interactiveAdvertisingBureauURL', '<a class="ci-link" href="' + urlIAB +'">' + linkIAB + '</a>');
            component.set('v.resultInfoText', infoText);
            component.set('v.visible', true);
            component. cookiesOff = $A.getCallback(function () {
                communityService.setCookie('RRCookies', 'agreed');
                component.set('v.visible', false);
                document.body.removeEventListener('click', component. cookiesOff, false);
            });
            document.body.addEventListener('click', component. cookiesOff, false);
            setTimeout($A.getCallback(function() {
                component .cookiesOff();
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