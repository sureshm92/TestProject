/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var initData = JSON.parse(returnValue);
            debugger;
            component.set('v.languages', initData.languages);
            component.set('v.locales', initData.locales);
            console.log(initData.languages);
            setTimeout($A.getCallback(function () {
                component.set('v.languageKey', initData.languageKey);
                component.set('v.localeKey', initData.localeKey);
                component.set('v.initialized', true);

            }), 10);
        })
    },

    doChangeLanguage: function(component){
        if(!component.get('v.initialized')) return;
        var languageKey = component.get('v.languageKey');
        var localeKey = component.get('v.localeKey');
        component.find('spinner').show();
        communityService.executeAction(component, 'changeLanguage', {
            languageKey: languageKey,
            localeKey: localeKey
        }, function () {
            location.reload()
        })
    }
})