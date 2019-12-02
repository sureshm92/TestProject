/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, hepler){
        var defaultLanguage = 'en_US';
        var language = communityService.getCookie('RRLanguage');
        var paramLanguage = communityService.getUrlParameter('language');

        if (language && paramLanguage && paramLanguage !== language) {
            document.location.href = communityService.replaceUrlParameter('language', language);
            return;
        } else if (!language) {
            var multiBrowserLanguage = navigator.language || navigator.userLanguage || navigator.browserLanguage || navigator.systemLanguage || DEFAULT_VALUE;
            var browserLanguages = JSON.stringify([multiBrowserLanguage]);
            //if supported languages list:
            if(navigator.languages) browserLanguages = JSON.stringify(navigator.languages);
            //load preferred language from server:
            communityService.executeAction(component, 'getPreferredLanguageCode', {
                browserLanguages: browserLanguages
            }, function (returnValue) {
                language = returnValue;
            }, function () {
                language = defaultLanguage;
            }, function () {
                communityService.setCookie('RRLanguage', language);
                document.location.href = communityService.replaceUrlParameter('language', language);
            });
            return;
        }
        component.set('v.languageChecked', true);
    }

})