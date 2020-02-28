/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    viewStudySite: function (component, event, helper) {
        var ssId = event.currentTarget.dataset.ssid;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Study_Site__c',
                recordId: ssId
            },
        };

        component.get('v.parent').find('navLink').navigate(pageRef);
    },

    sscCheckboxStateChange: function (component, event, helper) {
        var item = component.get('v.item');
        var asgCount = 0;
        var assignments = item.assignments;
        for (var j = 0; j < assignments.length; j++) {
            if (assignments[j].state) asgCount++;
        }
        item.emptyAssignments = asgCount === 0;
        component.set('v.item', item);
    },

    sscRadioStateChange: function (component, event, helper) {
        var selected = event.getSource().get("v.label");
        var item = component.get('v.item');
        var asgCount = 0;
        var assignments = item.assignments;
        console.log(selected);
        console.log(JSON.stringify(assignments));
        for (var j = 0; j < assignments.length; j++) {
            if (assignments[j].value !== selected) assignments[j].state = false;
            if (assignments[j].state) asgCount++;
        }
        item.emptyAssignments = asgCount === 0;
        component.set('v.item', item);
    }
});