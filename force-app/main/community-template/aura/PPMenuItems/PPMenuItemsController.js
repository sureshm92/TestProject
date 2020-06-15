/**
 * Created by Olga Skrynnikova on 6/10/2020.
 */

({
    doInit: function (component, event, helper) {
        let communityModes = [
            {
                isSelected: false,
                title: 'Hernya Delegate',
                subTitle: 'No active studies',
                subItems: []
            },
            {
                isSelected: false,
                title: 'Marcus Ray',
                subItems: [
                    {
                        title: 'Study Test 1',
                        isDelegate: true,
                        isSelected: true
                    },
                    {
                        title: 'Study Test 2',
                        isDelegate: true,
                        isSelected: false
                    },
                    {
                        title: 'Study Test 3',
                        isDelegate: true,
                        isSelected: false
                    }
                ]
            },

        ];
        component.set('v.allModes', communityModes);
    },

    doOnClick: function (component, event) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        component.getEvent('onclick').fire();
    },
});