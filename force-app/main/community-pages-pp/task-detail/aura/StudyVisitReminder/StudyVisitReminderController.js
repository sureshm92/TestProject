({
    doInit: function (component, event, helper) {
        //component.find('spinner').show();
        var params = event.getParam('arguments');
        if (params) {
            console.log('#relaodAttributes: ' + JSON.stringify(params.relaodAttributes));
            component.set('v.visitId', params.relaodAttributes.visitId);
            component.set('v.taskId', params.relaodAttributes.taskId);
            component.set('v.taskType', params.relaodAttributes.taskType);
            component.set('v.visitData', params.relaodAttributes.visitData);
            component.set('v.taskData', params.relaodAttributes.taskData);
            component.set('v.isNewTask', params.relaodAttributes.isNewTask);
            component.set('v.title', params.relaodAttributes.title);
            component.set('v.isReminderOnly', params.relaodAttributes.isReminderOnly);
        }

        helper.initialize(component, helper);
        //Take scroll bar to top next time when the popup is displayed
        //if (!component.get('v.isReminderOnly')) {
        document.getElementsByClassName('with-scroll')[0].scrollTop = 0;
        //}
    },

    doCancel: function (component, event, helper) {
        helper.hideModal(component);
    },

    doSave: function (component, event, helper) {
        debugger;
        var task = component.get('v.task');
        task.Task_Type__c = $A.util.isEmpty(task.Task_Type__c) &&
            !component.get('v.initData.createdByAdmin') ? 'Not Selected' : task.Task_Type__c;
        var reminderDate = component.get('v.initData.reminderDate');
        var emailPeferenceSelected = component.get('v.task.Remind_Using_Email__c');
        var smsPeferenceSelected = component.get('v.task.Remind_Using_SMS__c');
        var emailOptIn = component.get('v.emailOptIn');
        var smsOptIn = component.get('v.smsOptIn');
        console.log('smsPeferenceSelected: ' + smsPeferenceSelected + '  smsOptIn' + smsOptIn);
        console.log('emailPeferenceSelected: ' + emailPeferenceSelected + '  emailOptIn' + emailOptIn);

        if (!task.Subject) {
            communityService.showErrorToast('', $A.get('$Label.c.Empty_TaskName'), 3000);
            return;
        }
        if (!$A.util.isUndefinedOrNull(reminderDate)
            && !(smsPeferenceSelected && smsOptIn)
            && !(emailPeferenceSelected && emailOptIn)) {
            communityService.showErrorToast('', $A.get('$Label.c.PP_Remind_Using_Required'), 3000);
            return;
        }
        var isValidFields = helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component);
        if (!component.get('v.isValidFields') || !isValidFields) {
            var showToast = true;
            if (!component.get('v.isNewTask')) {
                if (component.get('v.jsonState') ===
                    (JSON.stringify(component.get('v.initData'))) + '' + JSON.stringify(task)) {
                    showToast = false;
                }
            }
            if (showToast) {
                communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'), 3000);
                return;
            }
        }

        var message = helper.setSuccessToast(component);

        console.log('#task: '+ JSON.stringify(task));

        component.find('spinner').show();

        communityService.executeAction(component, 'upsertTask', {
            'wrapper': JSON.stringify(component.get('v.initData')),
            'paramTask': JSON.stringify(task)
        }, function () {
            component.set('v.isSaveOperation', true);
            component.find('spinner').hide();
            communityService.showSuccessToast('', message, 3000);
            helper.hideModal(component);
        }, function () {
            component.find('spinner').hide();
        }, null);
    },

    doIgnore: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'ignoreTask');
    },

    doMarkComplete: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'markAsCompleted');
    },

    setOneDayBefore: function (component, event, helper) {
        var reminderDate = moment(component.get('v.initData.reminderDate'), 'YYYY-MM-DD');
        reminderDate.subtract(1, 'days');
        component.set('v.initData.reminderDate', reminderDate.format('YYYY-MM-DD'));
    },

    doValidateFields: function (component, event, helper) {
        var isValidFields = helper.doValidateDueDate(component, helper) &&
            helper.doValidateReminder(component);
        //helper.doValidateDueDateOnFreqChange(component);

        component.set('v.isValidFields', isValidFields);
    },

    doNavigateToAccountSettings: function (component, event, helper) {
        //communityService.navigateToPage('account-settings');
        window.open('account-settings', '_blank');
        window.focus();
        helper.hideModal(component);
    },

    setAttributeValue: function (component, event, helper) {
        var sourceEvt = event.getSource();
        switch (sourceEvt.get('v.name')) {
            case 'Email':
                component.set('v.task.Remind_Using_Email__c', sourceEvt.get('v.checked'));
                break;
            case 'SMS':
                component.set('v.task.Remind_Using_SMS__c', sourceEvt.get('v.checked'));
                break;
        }
    }
})