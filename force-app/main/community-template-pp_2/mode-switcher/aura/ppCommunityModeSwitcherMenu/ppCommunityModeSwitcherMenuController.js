({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    doSelectItem: function (component, event, helper) {
        let itemValue = event.getParam('itemValue');
        let navigateTo = event.getParam('navigateTo');
        var comModes = component.get('v.communityModes');
        let reloadRequired = false;
        let oldCommunityMode = communityService.getCurrentCommunityMode();
        if (navigateTo && !itemValue) {
            communityService.navigateToPage(navigateTo);
            component.set('v.reset', true);
            component.set('v.reset', false);
        } else if (itemValue) {
            if (itemValue.subItems.length === 0) {
                let currentDelegateId, currentEnrollmentId, communityName;
                if (itemValue.mode === 'Participant') {
                    currentDelegateId = itemValue.delegateId;
                    currentEnrollmentId = itemValue.peId;
                } else {
                    communityName = itemValue.communityName;
                }
                communityService.executeAction(
                    component,
                    'changeMode',
                    {
                        mode: itemValue.mode,
                        delegateId: currentDelegateId,
                        peId: currentEnrollmentId,
                        communityName: communityName,
                        communityModes: JSON.stringify(comModes)
                    },
                    function (returnValue) {
                        const comData = JSON.parse(returnValue);
                        component.set('v.currentMode', comData.currentMode);
                        try {
                            if (itemValue) {
                                let oldModeKey = oldCommunityMode.key;
                                let newModeKey = comData.currentMode.key;
                                if (oldModeKey != newModeKey) {
                                    reloadRequired = true;
                                }
                            }
                        } catch (e) {
                            console.log(e);
                        }
                        component.set('v.communityModes', comData.communityModes);

                        if (comData.currentMode.template.needRedirect) {
                            var networkId;
                            if (navigateTo == 'account-settings' || navigateTo == 'my-team') {
                                networkId = comData.currentMode.template.networkId;
                                comData.currentMode.template.redirectURL =
                                    comData.currentMode.template.currentCommunityURL +
                                    '/servlet/networks/switch?networkId=' +
                                    networkId +
                                    '&startURL=';
                            } else {
                                networkId = comData.currentMode.template.networkId;
                                comData.currentMode.template.redirectURL =
                                    comData.currentMode.template.currentCommunityURL +
                                    '/servlet/networks/switch?networkId=' +
                                    networkId +
                                    '&startURL=/s/';
                            }
                        }
                        communityService.setCurrentCommunityMode(comData.currentMode, navigateTo);
                        if (comData.currentMode.template.needRedirect) return;
                        if (!navigateTo) {
                            navigateTo = '';
                        }
                        communityService.navigateToPage(navigateTo);

                        component.set('v.reset', true);
                        component.set('v.reset', false);

                        if (
                            (reloadRequired && navigateTo == 'account-settings') ||
                            navigateTo != 'account-settings'
                        ) {
                            communityService.reloadPage();
                        }
                    }
                );
            }
        }
    },
    logout: function (component, event, helper) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(url + '/secur/logout.jsp');
        });
    },
    handleCardVisiblity: function (component, event, helper) {
        component.set('v.reset', true);
        component.set('v.reset', false);
    },
    //Reset the menue items.
    handleMessage: function (component, event, helper) {
        // Read the message argument to get the values in the message payload
        if (event != null && event.getParams() != null) {
            const message = event.getParam('reset_PP_Menue_Items');
            if (message) {
                helper.doInit(component, event, helper);
            }
        }
    }
});
