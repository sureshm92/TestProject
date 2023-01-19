/**
 * Created by Nargiz Mamedova on 6/11/2020.
 */

({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },

    handleApplicationEvent: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getSwitcherInitData',
            null,
            function (returnValue) {
                const userData = JSON.parse(returnValue);
                component.set('v.user', userData.user);
                component.set('v.hasProfilePic', userData.hasProfilePic);
                component.set('v.communityModes', userData.communityModes);
                component.set('v.currentMode', communityService.getCurrentCommunityMode());
            }
        );

        //$A.get('e.force:refreshView').fire();
    },

    doSelectItem: function (component, event, helper) {
        let navigateTo;
        let itemValue;
        if (component.get('v.templateName') == 'PatientPortal') {
            itemValue = event.getParam('itemValue');
            navigateTo = event.getParam('navigateTo');
        } else {
            const source = event.getParam('source');
            navigateTo = source.get('v.navigateTo');
            itemValue = source.get('v.itemValue');
        }
        var comModes = component.get('v.communityModes');
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
                } else if (itemValue.mode === 'HCP') {
                    currentDelegateId = itemValue.itemId;
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
                            if (
                                navigateTo == 'account-settings' ||
                                navigateTo == 'account-settings?manage-delegates'
                            ) {
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
                                component.find('pubsub').fireEvent('reload');
                            }
                        );
                    }
                );
            }
        }
    },

    handleShow: function (component, event, helper) {
        component.set(
            'v.initialCommunityModes',
            JSON.parse(JSON.stringify(component.get('v.communityModes')))
        );
    },

    handleBlur: function (component, event, helper) {
        const comModes = component.get('v.initialCommunityModes');
        component.set('v.communityModes', comModes);
    },

    logout: function (component, event, helper) {
        sessionStorage.clear();
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
