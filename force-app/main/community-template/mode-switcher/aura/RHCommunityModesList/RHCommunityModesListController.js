/**
 * Created by Andrii Kryvolap
 */
({
    doInit: function (component, event, helper) {
        let communityModes = [
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
        ];
        component.set('v.communityModesList', communityModes);
    },
    doToggleGroup: function (component, event, helper) {
        let communityModes = component.get('v.communityModesList');
        let selectedGroupId = event.currentTarget.dataset.groupId;

        for (let i=0; i<communityModes.length; i++ ){
            if (communityModes[i].itemType === selectedGroupId){
                communityModes[i].isCollapsed = !communityModes[i].isCollapsed;
            }
        }
        component.set('v.communityModesList', communityModes);
    },
    doSwitchMode: function (component, event, helper) {
        let targetDataset = event.currentTarget.dataset;
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParams({
            "itemType": targetDataset.groupId,
            "itemId": targetDataset.delegateId
        });
        onclickEvent.fire();
    }
})