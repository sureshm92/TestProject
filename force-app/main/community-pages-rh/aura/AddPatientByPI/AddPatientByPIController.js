/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            let ssId = communityService.getUrlParameter('ssId');

            component.find('spinner').show();
            communityService.executeAction(component, 'getInitData', {
                ssId: ssId
            }, function (formData) {
                component.set('v.ctp', formData.ctp);
                component.set('v.ss', formData.ss);
                component.set('v.formData', formData);
                component.set('v.initialized', true);
                component.set('v.userLanguage', formData.userLanguage);
                console.log('LANGUAGE', component.get('v.userLanguage'));
                window.setTimeout(
                    $A.getCallback(function () {
                        helper.initData(component);
                    }), 100
                );
            }, null, function () {
                component.find('spinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doCancel: function (component) {
        communityService.navigateToHome();
    },

    doSaveAndExit: function (component, event, helper) {
        helper.createParticipant(component, function () {
            communityService.navigateToHome();
        })
    },

    doSaveAndNew: function (component, event, helper) {
        helper.createParticipant(component, function () {
            helper.initData(component);
        })
    }
})