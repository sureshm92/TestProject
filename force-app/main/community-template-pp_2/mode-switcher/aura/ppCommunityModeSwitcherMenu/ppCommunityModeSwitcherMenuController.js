({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getSwitcherInitData', null, function (
            returnValue
        ) {
            const userData = JSON.parse(returnValue);
            component.set('v.user', userData.user);
            component.set('v.hasProfilePic', userData.hasProfilePic);
            component.set('v.communityModes', userData.communityModes);
            component.set(
                'v.initialCommunityModes',
                JSON.parse(JSON.stringify(component.get('v.communityModes')))
            );
            component.set('v.currentMode', communityService.getCurrentCommunityMode());
        });
    },
    doSelectItem: function (component, event, helper) {    
           let itemValue = event.getParam('itemValue');
           let navigateTo = event.getParam('navigateTo');        
        var comModes = component.get('v.communityModes');
        let reloadRequired = false;
        try {
            if (itemValue) {
                let newCurrentPE = JSON.parse(JSON.stringify(itemValue)).peId;
                let currentPE = communityService.getCurrentCommunityMode().currentPE;
                if (newCurrentPE != currentPE) {
                    reloadRequired = true;
                }
            }
        } catch (e) {
            console.log(e);
        }
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

                        communityService.executeAction(
                            component,
                            'getCommunityUserVisibility',
                            null,
                            function (userVisibility) {
                                communityService.setMessagesVisible(userVisibility.messagesVisible);
                                communityService.setTrialMatchVisible(
                                    userVisibility.trialMatchVisible
                                );
                                communityService.setEDiaryVisible(userVisibility.eDiaryVisible);
                                component.getEvent('onModeChange').fire();
                                //component.find('pubsub').fireEvent('reload');
                                if (
                                    (reloadRequired && navigateTo == 'account-settings') ||
                                    navigateTo != 'account-settings'
                                ) {
                                communityService.reloadPage();
                                } else {
                                    component.find('pubsub').fireEvent('reload');
                                }
                            }
                        );
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
    }
});
