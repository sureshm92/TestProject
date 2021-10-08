({
    doInit: function(component, event, helper) {
        console.log('doInit: ' + component.get('v.recordId'));
        communityService.executeAction(
            component,
            'getTaskDetails',
            {
                configId: component.get('v.recordId')
            },
            function(value) {
                var today = new Date();
                today = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
                console.log('date: ' + $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
                if (value) {
                    component.set('v.recTask', value);
                }
                if (
                    value.Start_Date__c > today &&
                    value.Start_Date__c == value.Next_Occurence_Date__c
                ) {
                    console.log('Future task: ');
                    component.set('v.futureTask', true);
                    //communityService.showToast('Success', 'Success', 'Recurring task removed');
                }
                console.log('Task: ' + component.get('v.recTask'));
            },
            null,
            function() {
                component.set('v.showSpinner', false);
            }
        );
    },
    handleConfirm: function(component, event, helper) {
        console.log('Confirm: ');
        communityService.executeAction(
            component,
            'removeRecurrence',
            {
                configId: component.get('v.recordId')
            },
            function(value) {
                console.log('val: ' + value);
                communityService.showToast('Success', 'Success', 'Task Recurrence removed');
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
            },
            null,
            function() {
                component.set('v.showSpinner', false);
            }
        );
    },
    handleCancelTaskTask: function(component, event, helper) {
        communityService.executeAction(
            component,
            'cancelTask',
            {
                configId: component.get('v.recordId')
            },
            function(value) {
                console.log('val: ' + value);
                communityService.showToast('Success', 'Success', 'Task cancelled');
                $A.get('e.force:refreshView').fire();
            },
            null,
            function() {
                component.set('v.showSpinner', false);
            }
        );
    },
    handleRemoveFutureTask: function(component, event, helper) {
        console.log('Confirm: ');
        communityService.executeAction(
            component,
            'removeRecurrence',
            {
                configId: component.get('v.recordId')
            },
            function(value) {
                console.log('val: ' + value);
                communityService.showToast('Success', 'Success', 'Task cancelled');
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
            },
            null,
            function() {
                component.set('v.showSpinner', false);
            }
        );
    },
    handleCancel: function(component, event, helper) {
        console.log('Cancel: ');
        var compEvent = component.getEvent('closeModalEvent');
        compEvent.setParams({ message: 'close' });
        compEvent.fire();
    }
});
