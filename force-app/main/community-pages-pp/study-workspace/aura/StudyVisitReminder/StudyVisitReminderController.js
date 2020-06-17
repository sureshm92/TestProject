({
    doInit: function (component, event, helper) {
        var taskId = component.get('v.taskId');
        var isNewTask = component.get('v.isNewTask');
        
        if (!communityService.isDummy()) {
            component.find('spinner').show();
            communityService.executeAction(component, 'getTaskEditData', {
                taskId: isNewTask ? null : taskId
            }, function (wrapper) {
                component.set('v.initData', wrapper);
                component.set('v.isEnrolled', wrapper.isEnrolled);
                component.set('v.isEmailReminderSet', wrapper.isEmailReminderSet);
                component.set('v.isSMSReminderSet', wrapper.isSMSReminderSet);

                if ((wrapper.isEmailReminderSet || wrapper.isSMSReminderSet) && wrapper.reminderDate) {
                    component.set('v.reminderDateEnabled', true);
                    if (wrapper.activityDate) {
                        component.set('v.frequencyEnabled', true);
                    }
                }

                component.set('v.taskTypeList', wrapper.taskTypeList);

                var task = wrapper.task;
                if (isNewTask) {
                    if (wrapper.activityDate && wrapper.reminderDate) {
                        var due = moment(wrapper.activityDate, 'YYYY-MM-DD');
                        var reminder = moment(wrapper.reminderDate, 'YYYY-MM-DD');
                        if (!due.isSame(reminder)) {
                            if (due.diff(reminder, 'days') === 1) {
                                component.set('v.frequencyMode', 'Day_Before');
                                component.set('v.reminderDateEnabled', false);
                            }
                        }
                    }

                    var isOwner = task.OwnerId === task.CreatedById;
                    component.set('v.owner', isOwner);
                    component.set('v.isEditable', isOwner && task.Status !== 'Completed');
                    
                } else {
                    component.set('v.isEditable', true);

                    task.Status = 'Open';
                    task.Task_Type__c = 'Not Selected';
                }
                component.set('v.task', task);

                var visitId = component.get('v.visitId');
                if (!$A.util.isUndefinedOrNull(visitId)) {
                    component.set('v.task.Patient_Visit__c', visitId);
                }

                component.set('v.jsonState', JSON.stringify(wrapper) + '' + JSON.stringify(task));
                component.set('v.isValidFields', true);
                component.find('spinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
        component.find('reminderModal').show();
    },

    doCancel: function (component, event, helper) {
        component.find('reminderModal').hide();
    },

    doSave: function (component, event, helper) {

    },

    doIgnore: function (component, event, helper) {

    },

    doMarkComplete: function (component, event, helper) {

    }
})