({
    initialize: function (component) {
        var taskId = component.get('v.taskId');
        var isNewTask = component.get('v.isNewTask');
        var visitId = component.get('v.visitId');
        var visitData = component.get('v.visitData');
        var taskType = component.get('v.taskType');
		
        if (!communityService.isDummy()) {
            component.find('spinner').show();
            communityService.executeAction(component, 'getTaskEditData', {
                taskId: isNewTask ? null : taskId
            }, function (wrapper) {
                console.log('##wrapper: ' + JSON.stringify(wrapper));
                component.set('v.initData', wrapper);
                component.set('v.isEnrolled', wrapper.isEnrolled);
                component.set('v.isEmailReminderSet', wrapper.isEmailReminderSet);
                component.set('v.isSMSReminderSet', wrapper.isSMSReminderSet);

                if (!wrapper.isEmailReminderSet || !wrapper.isSMSReminderSet) {
                    component.set('v.showAccountNavigation', true);
                }

                component.set('v.taskTypeList', wrapper.taskTypeList);

                var task = wrapper.task;
                if (isNewTask) {
                    if (taskType === 'Visit') {
                        task.Subject = visitData.visitName;
                        //wrapper.activityDate = null; //visitData.completedOrPlannedDate;
                    }
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

    updateTaskStatus: function (component, helper, method) {
        component.find('spinner').show();
        communityService.executeAction(component, method, {
            'taskId': component.get('v.taskId')
        }, function () {
            component.find('spinner').hide();
        }, null, function () {
            helper.hideModal(component);
        });
    },

    //Just for safe-keeping. Might use it when Planned_Date_c
    //for Patient Visit is populated by SDH
    isSameDay: function (component) {
        var today = component.get('v.initData.today');
        var dueDate = component.get('v.initData.activityDate');
        dueDate = moment(dueDate, 'YYYY-MM-DD');

        return dueDate.isSame(today);
    },

    hideModal: function (component) {
        component.find('reminderModal').hide();
    }
})
