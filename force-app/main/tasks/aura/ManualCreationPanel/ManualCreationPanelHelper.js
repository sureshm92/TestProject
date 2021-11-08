/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    reset: function(component) {
        component.set('v.remDays', 0);
        $A.get('e.force:refreshView').fire();
        //$A.enqueueAction(component.get('c.doInit'));
    },

    checkChild: function(component, validity) {
        var currentTab = component.get('v.selectedTab');
        let manTask = component.find('manTask');
        let manAdhoc = component.find('manAdhoc');
        if (currentTab === 'task') {
            if (manTask) {
                validity = validity && component.find('manTask').get('v.isValid');
            }
        } else if (currentTab === 'adHoc') {
            if (manAdhoc) {
                validity = validity && component.find('manAdhoc').get('v.isValid');
            }
        }

        return validity;
    },
    checkChildSave: function(component, validity) {
        if (component.find('manTask')) {
            validity = validity && component.find('manTask').get('v.isValidSave');
        }
        return validity;
    }
});
