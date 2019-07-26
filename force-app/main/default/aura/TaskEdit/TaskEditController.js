/**
 * Created by mkotenev on 3/4/2019.
 */
({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);

        var paramTaskId = communityService.getUrlParameter('id');
        if (paramTaskId === undefined) paramTaskId = null;

        communityService.executeAction(component, 'getTaskEditData', {
            'taskId': paramTaskId
        }, function (wrapper) {
            component.set('v.initData', wrapper);
            component.set('v.notReferral', wrapper.notReferral);
            component.set('v.reminderEnabled', wrapper.reminderEnabled);
            component.set('v.reminderDateEnabled', true);

            var task = wrapper.task;
            component.set('v.task', task);

            var visitId = communityService.getUrlParameter('visitId');
            if (visitId) component.set('v.task.Patient_Visit__c', visitId);

            if (wrapper.reminderEnabled && task.ActivityDate) {
                component.set('v.frequencyEnabled', true);
            }
            if (wrapper.reminderEnabled && component.get('v.task.ActivityDate')) {
                component.set('v.frequencyEnabled', true);
            }

            if (!component.get('v.task.ActivityDate')) {
                component.set('v.disableFrequency', true);
            }
            component.set('v.taskTypeList', wrapper.taskTypeList);
            if (paramTaskId) {
                component.set('v.editMode', true);

                var isOwner = task.OwnerId === task.CreatedById;
                component.set('v.owner', isOwner);
                component.set('v.editAvailable', isOwner && task.Status !== 'Completed');
            } else {
                component.set('v.editMode', false);
                component.set('v.editAvailable', true);
                component.set('v.task.Status', 'Open');
            }
            component.find('spinner').hide();
        });
    },

    doCancel: function (component, event, helper) {
        component.find('spinner').show();
        window.history.go(-1);
    },

    doSave: function (component, event, helper) {
        var isValid = component.get('v.isValidFields');

        var task = component.get('v.task');
        if (!task.Subject) {
            communityService.showErrorToast('', 'Task Name cannot be empty');
            return;
        }

        var dueDate = task.ActivityDate;
        if (dueDate && !isValid) {
            component.set('v.task.ActivityDate', null);
            communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'));
            return;
        }

        if (component.get('v.reminderDateEnabled') && component.get('v.reminderSetMode') === 'Email') {
            var reminderDate = task.Reminder_Date__c;
            if (reminderDate){
                if(isValid) {
                    component.set('v.task.Reminder_Date__c', new Date(reminderDate));
                }
                else {
                    communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'));
                    return;
                }
            } else {
                communityService.showErrorToast('', $A.get('$Label.c.Empty_Reminder'));
                return;
            }
        }

        component.find('spinner').show();
        communityService.executeAction(component, 'upsertTask', {
            'paramTask': JSON.stringify(task)
        }, function () {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doMarkAsCompleted: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'markAsCompleted', {
            'paramTask': component.get('v.task')
        }, function (string) {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doIgnoreTask: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'ignoreTask', {
            'taskId': component.get('v.task.Id')
        }, function () {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    onChangeFreq: function (component, event, helper) {
        var freq = event.getSource().get('v.value');

        if (freq === 'By_Date') {
            component.set('v.reminderDateEnabled', true);
        } else if (freq === 'Day_Before') {
            $A.enqueueAction(component.get('c.changeReminderDate'));
            component.set('v.reminderDateEnabled', false);
        }
    },

    onChangeSetReminder: function (component, event, helper) {
        var reminderSetMode = component.get('v.reminderSetMode');

        if (reminderSetMode === 'Disabled') {
            component.set('v.frequencyEnabled', false);
            component.set('v.reminderDateEnabled', false);
            component.set('v.task.Reminder_Date__c', null);
        } else if (reminderSetMode === 'Email') {
            var dueDate = component.get('v.task.ActivityDate');
            if (dueDate && component.get('v.isValidFields')) {
                component.set('v.frequencyEnabled', true);
            }
            component.set('v.reminderDateEnabled', true);
        }
    },

    onChangeDueDate: function (component, event, helper) {
        var dueDate = component.get('v.task.ActivityDate');
        var frequencyMode = component.get('v.frequencyMode');

        if (!dueDate) {
            component.set('v.frequencyEnabled', false);
            if (component.get('v.reminderEnabled')) component.set('v.reminderDateEnabled', true);
        }

        if (component.get('v.reminderSetMode') === 'Email') {
            if (dueDate) {
                if (frequencyMode === 'Day_Before') $A.enqueueAction(component.get('c.changeReminderDate'));
                component.set('v.frequencyEnabled', true);
            } else {
                frequencyMode.set('By_Date');
                component.set('v.frequencyEnabled', false);
            }
        }

        if (frequencyMode === 'By_Date') {
            component.set('v.task.Reminder_Date__c', dueDate);
        }
        if (dueDate) component.set('v.frequencyEnabled', true);
    },

    changeReminderDate: function (component, event, helper) {
        var dueDate = new Date(component.get('v.task.ActivityDate'));
        dueDate.setUTCHours(12, 0, 0, 0);

        if (component.get('v.task.ActivityDate') !== component.get('v.todayDate')) {
            dueDate.setDate(dueDate.getDate() - 1);
        }

        var oneDayBefore = $A.localizationService.formatDate(dueDate, 'YYYY-MM-DD');
        component.set('v.task.Reminder_Date__c', oneDayBefore);
    },

    doCheckFields: function (component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);
        debugger;
        component.set('v.isValidFields', allValid);
    }
});