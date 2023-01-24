/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.languages', initData.languages);
            component.set('v.optionalLanguages', initData.optionalLanguages);
            component.set('v.locales', initData.locales);
            component.set('v.timezones', initData.timezones);
            console.log(initData.languages);
            setTimeout(
                $A.getCallback(function () {
                    component.set('v.languageKey', initData.languageKey);
                    component.set('v.secondLangKey', initData.secondLangKey);
                    component.set('v.thirdLangKey', initData.thirdLangKey);
                    component.set('v.localeKey', initData.localeKey);
                    component.set('v.timezoneKey', initData.timezoneKey);
                    component.set('v.initialized', true);
                }),
                10
            );
        });
    },

    doChangeLanguage: function (component) {
        if (!component.get('v.initialized')) return;
        var languageKey = component.get('v.languageKey');
        var secondLangKey = component.get('v.secondLangKey');
        var thirdLangKey = component.get('v.thirdLangKey');
        var localeKey = component.get('v.localeKey');
        var timezoneKey = component.get('v.timezoneKey');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'changeLanguage',
            {
                languageKey: languageKey,
                secondLangKey: secondLangKey,
                thirdLangKey: thirdLangKey,
                localeKey: localeKey,
                timezoneKey: timezoneKey
            },
            function () {
                communityService.reloadPage();
            },
            function () {
                component.find('spinner').hide();
            }
        );
    }
});
