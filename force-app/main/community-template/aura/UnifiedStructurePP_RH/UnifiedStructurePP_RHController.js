/**
 * Created by Olga Skrynnikova on 6/16/2020.
 */

({
    doInit: function (component, event, helper) {
        let communityModes = [
            {
                isPPItemsCollapsed: false,
                isRHItemsCollapsed: false,
                isPPItemsSelected: false,
                isRHItemsSelected: true,
                ppModeItems: [
                    {
                        title: 'Hernya Delegate',
                        isDelegate: false,
                        subItems: [
                            {
                                title: 'Hernya Delegate',
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
            }
        ];
        component.set('v.communityModes', communityModes);
    }
});