/**
 * Created by Nargiz Mamedova on 6/11/2020.
 */

({
    doInit: function (component, event, helper) {
        let communityModes = {
            isPPItemsCollapsed: false,
            isRHItemsCollapsed: false,
            isPPItemsSelected: false,
            isRHItemsSelected: true,
            type: 'PP_And_RH',
            ppModeItems: [
                {
                    title: 'Del Delegate',
                    isDelegate: false,
                    subItems: [
                        {
                            title: 'Del Delegate',
                            subTitle: 'No active studies',
                            isDelegate: true,
                            isSelected: true
                        }
                    ]
                }
            ],
            rhModeItems: [
                {
                    isGroup: false,
                    isSelected: false,
                    isCollapsed: false,
                    title: 'View as Investigative Site',
                    itemType: 'PI',
                    itemId: '',
                    subItems: []
                },
                {
                    isGroup: true,
                    isSelected: true,
                    isCollapsed: false,
                    title: 'View as Referring Provider',
                    itemType: 'RP',
                    itemId: '',
                    subItems: [
                        {
                            isGroup: false,
                            isSelected: true,
                            isCollapsed: false,
                            title: 'Dr. Oliver Scott',
                            itemType: 'RP',
                            itemId: '',
                            subItems: []
                        },
                        {
                            isGroup: false,
                            isSelected: false,
                            isCollapsed: false,
                            title: 'Dr. Lana Liama',
                            itemType: 'RP',
                            itemId: '0912321324234',
                            subItems: []
                        }
                    ]
                }
            ]
        };
        component.set('v.communityModes', communityModes);
        // communityService.executeAction(component, 'getSwitcherInitData', null, function (returnValue) {
        //     const userData = JSON.parse(returnValue);
        //     component.set('v.user', userData.user);
        //     component.set('v.communityModes', userData.communityModes);
        //     component.set('v.currentMode', communityService.getCurrentCommunityMode());
        // });
    },

    logout: function (component, event, helper) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(url + "/secur/logout.jsp");
        })
    }
});