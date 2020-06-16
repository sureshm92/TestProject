/**
 * Created by Olga Skrynnikova on 6/10/2020.
 */

({
    doInit: function (component, event, helper) {
        let communityModes = [
            {
                title: 'Hernya Delegate',
                isDelegate: false,
                subItems: [
                    {
                        title: 'Hernya Delegate',
                        subTitle: 'No active studies',
                        isDelegate: true,
                        isSelected: false
                    }
                ]
            },
            {
                title: 'Marcus Ray',
                isDelegate: true,
                subItems: [
                    {
                        title: 'Marcus Ray',
                        subTitle: 'Study Test 1',
                        isDelegate: true,
                        isSelected: true
                    },
                    {
                        title: 'Marcus Ray',
                        subTitle: 'Study Test 2',
                        isDelegate: true,
                        isSelected: false
                    },
                    {
                        title: 'Marcus Ray',
                        subTitle: 'Study Test 3',
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