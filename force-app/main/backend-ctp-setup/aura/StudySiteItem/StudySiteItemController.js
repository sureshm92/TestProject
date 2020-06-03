/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    doInit: function (component, event, helper) {
        if (component.get('v.fromComponent') === 'Incentive') {
            let assignments = component.get('v.item.assignments');
            if (assignments) {
                for (var j = 0; j < assignments.length; j++) {
                    if (assignments[j] && assignments[j].state && !component.get('v.selectedItem')) {
                        component.set('v.selectedItem', assignments[j].value);

                        let allSelectedIPs = component.get('v.selectedGlobalItems');
                        allSelectedIPs[assignments[j].value].add(component.get('v.item').ss.Id);
                        component.set('v.selectedGlobalItems', allSelectedIPs);

                        break;
                    }
                }
            }
        }
    },

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
        let isIncetive = component.get('v.fromComponent') === 'Incentive';

        var item = component.get('v.item');
        var asgCount = 0;
        var assignments = item.assignments;
        let parent = component.get('v.parent');

        for (var j = 0; j < assignments.length; j++) {
            if (isIncetive) {
                let selectedItem = component.get('v.selectedItem');
                if (selectedItem && selectedItem !== assignments[j].value && assignments[j].state) {
                    assignments[j].state = false;
                    communityService.showWarningToast('Warning!', $A.get('$Label.c.PG_Ref_L_One_Incentive_Plan'), 5000);
                } else if (selectedItem && selectedItem === assignments[j].value && !assignments[j].state) {
                    component.set('v.selectedItem', '');

                    let allSelectedIPs = component.get('v.selectedGlobalItems');
                    allSelectedIPs[assignments[j].value].delete(component.get('v.item').ss.Id);
                    component.set('v.selectedGlobalItems', allSelectedIPs);
                } else if (!selectedItem && assignments[j].state) {
                    component.set('v.selectedItem', assignments[j].value);

                    let allSelectedIPs = component.get('v.selectedGlobalItems');
                    allSelectedIPs[assignments[j].value].add(component.get('v.item').ss.Id);
                    component.set('v.selectedGlobalItems', allSelectedIPs);
                }
            }

            if (assignments[j].state) asgCount++;
        }
        item.emptyAssignments = asgCount === 0;
        component.set('v.item', item);
        parent.doSave();
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