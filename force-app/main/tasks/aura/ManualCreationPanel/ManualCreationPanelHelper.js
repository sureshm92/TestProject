/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    reset: function (component) {
        $A.enqueueAction(component.get('c.doInit'));
    },

    checkChild: function (component, validity) {
        var currentTab = component.get('v.selectedTab');
        if (currentTab === 'task') {
            validity = validity && component.find('manTask').get('v.isValid');
        } else if (currentTab === 'adHoc') {
            validity = validity && component.find('manAdhoc').get('v.isValid');
        }

        return validity;
    }
});
