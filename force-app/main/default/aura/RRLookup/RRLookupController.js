({
    onSelect : function(component, event, helper) {
        let recordId = component.get('v.selectedLookup')[0];
        console.log(JSON.stringify(component.get('v.selectedRecords')));
        // console.log(recordId);
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
    },

    onRemoveSelectedItem : function(component, event, helper) {
        let selectedRecords = component.get('v.selectedRecords');
        let recordToRemove = event.getSource().get('v.name');
        console.log(JSON.stringify(event.getSource().get('v.label')));

        helper.removeFromArray(selectedRecords, recordToRemove);
        component.set('v.selectedRecords', selectedRecords);
        helper.fillValueWithIds(selectedRecords, component);
    },
});