/**
 * Created by Nargiz Mamedova on 6/11/2020.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getSwitcherInitData', null, function (returnValue) {
            const userData = JSON.parse(returnValue);
            component.set('v.user', userData.user);
            component.set('v.communityModes', userData.communityModes);
            component.set('v.currentMode', communityService.getCurrentCommunityMode());
        });
    },

    doSelectItem: function (component, event, helper) {
        const source = event.getParam('source');
        let navigateTo = source.get('v.navigateTo');
        const itemValue = source.get('v.itemValue');
        var comModes = component.get('v.communityModes');
        if(navigateTo && !itemValue) {
            communityService.navigateToPage(navigateTo);
        } else if (itemValue) {
            if (itemValue.subItems.length === 0) {
                let currentDelegateId;
                let currentEnrollmentId;
                if (itemValue.mode === 'Participant') {
                    currentDelegateId = itemValue.delegateId;
                    currentEnrollmentId = itemValue.peId;
                } else {
                    currentDelegateId = itemValue.itemId;
                    currentEnrollmentId = null;
                }
                communityService.executeAction(component, 'changeMode', {
                    mode: itemValue.mode,
                    delegateId: currentDelegateId,
                    peId: currentEnrollmentId,
                    communityModes: JSON.stringify(comModes)
                }, function (returnValue) {
                    const comData = JSON.parse(returnValue);
                    component.set('v.currentMode', comData.currentMode);
                    component.set('v.communityModes', comData.communityModes);
                    communityService.setCurrentCommunityMode(comData.currentMode);

                    if (!navigateTo) {
                        if (communityService.getUserMode() === 'Participant') {
                            navigateTo = communityService.getFullPageName();
                        } else {
                            navigateTo = '';
                        }
                    }
                    communityService.navigateToPage(navigateTo);

                    component.set('v.reset', true);
                    component.set('v.reset', false);

                    communityService.executeAction(component, 'getCommunityUserVisibility', null, function (userVisibility) {
                        communityService.setMessagesVisible(userVisibility.messagesVisible);
                        communityService.setTrialMatchVisible(userVisibility.trialMatchVisible);
                        component.getEvent('onModeChange').fire();
                        component.find('pubsub').fireEvent('reload');
                    });
                });
            }
        }
    },

    logout: function (component, event, helper) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(url + "/secur/logout.jsp");
        })
    }
});