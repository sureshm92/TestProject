({
    onSelect : function(component, event, helper) {
        let recordId = component.get('v.selectedLookup')[0];
        if (recordId != null){
            let recordData = component.find('recordData');
            recordData.set('v.recordId', recordId);
            recordData.reloadRecord(true);
        }
    },

    handleRecordUpdated : function(component, event, helper) {
        let selectedRecords = component.get('v.selectedRecords');
        let newRecord = component.get('v.record');
        let newRecordClone = {};
        Object.assign(newRecordClone, newRecord);
        if (!helper.containsObject(selectedRecords, newRecordClone)){
            selectedRecords.push(newRecordClone);
        }
        component.set('v.selectedRecords', selectedRecords);
        component.set('v.selectedLookup', null);
        helper.fillValueWithIds(selectedRecords, component);
        let changeAction = component.get('v.onchange');
        if (changeAction) $A.enqueueAction(changeAction);
    },

    onRemoveSelectedItem : function(component, event, helper) {
        let selectedRecords = component.get('v.selectedRecords');
        let recordToRemove = event.getSource().get('v.name');
        helper.removeFromArray(selectedRecords, recordToRemove);
        component.set('v.selectedRecords', selectedRecords);
        helper.fillValueWithIds(selectedRecords, component);
        let changeAction = component.get('v.onchange');
        if (changeAction) $A.enqueueAction(changeAction);
    },

    navigateToRecord : function(component, event, helper) {
        let recordId = event.getSource().get('v.name');
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "Related",
            "isredirect": 'true'
        });
        navEvt.fire();
    },

    onClearSelection : function (component, event, helper) {
        component.set('v.selectedRecords', []);
        let changeAction = component.get('v.onchange');
        if (changeAction) $A.enqueueAction(changeAction);
    }
});