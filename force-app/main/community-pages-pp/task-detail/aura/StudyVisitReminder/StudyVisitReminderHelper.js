({
    initialize: function (component, helper) {
        var taskId = component.get('v.taskId');
        var isNewTask = component.get('v.isNewTask');
        var visitId = component.get('v.visitId');
        var visitData = component.get('v.visitData');
        var taskType = component.get('v.taskType');
        component.set('v.isUpcoming', component.get('v.isUpcomingVisits'));
        // component.set('v.isValidFields',false);
        if (!communityService.isDummy()) {
            communityService.executeAction(
                component,
                'getTaskEditData',
                {
                    taskId: taskId
                },
                function (wrapper) {
                    console.log('##wrapper: ' + JSON.stringify(wrapper));
                    component.set('v.initData', wrapper);
                    component.set('v.isEnrolled', wrapper.isEnrolled);
                    component.set('v.emailOptIn', wrapper.emailOptIn);
                    component.set('v.smsOptIn', wrapper.smsOptIn);
                    if (!wrapper.emailOptIn || !wrapper.smsOptIn) {
                        component.set('v.showAccountNavigation', true);
                    }

                    component.set('v.taskTypeList', wrapper.taskTypeList);
                    var task = wrapper.task;
                    console.log('##isNewTask: ' + isNewTask);
                    if (isNewTask) {
                        if (taskType === 'Visit') {
                            task.Subject = visitData.visit.Is_Adhoc__c
                                ? $A.get('$Label.c.StudyVisit_Unscheduled_Visit')
                                : visitData.visit.Visit__r.Patient_Portal_Name__c;
                            wrapper.activityDate =
                                visitData.completedOrPlannedDate ==
                                $A.get('$Label.c.Study_Visit_Unavailable')
                                    ? null
                                    : visitData.completedOrPlannedDate; //moment(visitData.completedOrPlannedDate, 'YYYY-MM-DD');
                            component.set('v.isEditable', false);
                        }
                        task.Status = 'Open';
                        task.Task_Type__c = taskType;
                    } else {
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
                        component.set(
                            'v.editAvailable',
                            isOwner && task.Status !== 'Completed' && taskType !== 'Visit'
                        );
                        var reminderFrequencyVisits = [
                            {
                                label: $A.get('$Label.c.PP_NO_REMINDER'),
                                value: 'No reminder'
                            },
                            {
                                label: $A.get('$Label.c.PP_One_Hour_Before'),
                                value: '1 hour before'
                            },
                            {
                                label: $A.get('$Label.c.PP_Four_Hours_Before'),
                                value: '4 hours before'
                            },
                            {
                                label: $A.get('$Label.c.One_day_before'),
                                value: '1 day before'
                            },
                            {
                                label: $A.get('$Label.c.PP_One_Week_Before'),
                                value: '1 week before'
                            },
                            {
                                label: $A.get('$Label.c.PP_Custom'),
                                value: 'Custom'
                            }
                        ];
                        if (taskType === 'Visit' && wrapper.reminderDate) {
                            component.set(
                                'v.initData.reminderFrequencyList',
                                reminderFrequencyVisits
                            );
                        }
                    }
                    component.set('v.task', task);
                    if (component.get('v.initData.createdByAdmin')) {
                        var reminderFrequencyForAdmintask = [
                            {
                                label: $A.get('$Label.c.PP_NO_REMINDER'),
                                value: 'No reminder'
                            },
                            {
                                label: $A.get('$Label.c.PP_Custom'),
                                value: 'Custom'
                            }
                        ];
                        component.set(
                            'v.initData.reminderFrequencyList',
                            reminderFrequencyForAdmintask
                        );
                        if (!$A.util.isUndefinedOrNull(component.get('v.task'))) {
                            component.set('v.task.Remind_Me__c', 'Custom');
                        }
                    } else {
                        component.set('v.task.Remind_Me__c', task.Remind_Me__c);
                    }
                    if (!$A.util.isUndefinedOrNull(visitId)) {
                        component.set('v.task.Patient_Visit__c', visitId);
                    }
                    component.set(
                        'v.jsonState',
                        JSON.stringify(wrapper) + '' + JSON.stringify(task)
                    );
                    component.set('v.isValidFields', false);
                    let today = wrapper.today;
                    component.set('v.tomorrow', helper.addADay(component, today));
                    if (wrapper.activityDate) {
                        let activityDate = wrapper.activityDate;
                        component.set('v.dayAfterDueDate', helper.addADay(component, activityDate));
                    }
                    //component.find('spinner').hide();
                    component.find('reminderModal').show();
                }
            );
        } else {
            //component.find('spinner').hide();
            component.find('builderStub').setPageName(component.getName());
        }
    },

    updateTaskStatus: function (component, helper, method) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            method,
            {
                taskId: component.get('v.taskId')
            },
            function () {
                component.find('spinner').hide();
                component.set('v.isSaveOperation', true);
            },
            null,
            function () {
                helper.hideModal(component);
            }
        );
    },

    addADay: function (component, paramDate) {
        paramDate = moment(paramDate, 'YYYY-MM-DD').add(1, 'days');
        return paramDate.format('YYYY-MM-DD');
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
        var isSaveOperation = component.get('v.isSaveOperation');
        component.find('reminderModal').hide();
        //Re-initialize the parent table to display the updates
        if (isSaveOperation) {
            component.set('v.isSaveOperation', false);
            if (!component.get('v.isUpcoming')) {
                component.get('v.parent').reload();
            } else {
                $A.get('e.force:refreshView').fire();
            }
        }
    },

    setSuccessToast: function (component) {
        var isReminderOnly = component.get('v.isReminderOnly');
        var isNewTask = component.get('v.isNewTask');
        //Task created successfully. ; Changes are successfully saved. ; Visit reminder created successfully. ; Visit reminder updated.
        //var successToastArray = $A.get('$Label.c.PP_Task_Success_Toast').split(';');
        var message = '';
        if (isNewTask && !isReminderOnly) {
            //message = successToastArray[0].trim();
            message = $A.get('$Label.c.PP_TaskCreationSuccess');
            //Task created successfully.
        } else if (isNewTask && isReminderOnly) {
            //message = successToastArray[4].trim();
            message = $A.get('$Label.c.PP_VisitScheduledSuccess');
            //Visit scheduled successfully.
        } else if (!isNewTask && isReminderOnly) {
            //message = successToastArray[1].trim();
            message = $A.get('$Label.c.PP_ChangesSuccessfullySaved');
            //Changes are successfully saved.
        } else if (!isNewTask && !isReminderOnly) {
            message = $A.get('$Label.c.PP_ChangesSuccessfullySaved');
            //message = successToastArray[1].trim();
            //Changes are successfully saved.
        } else {
            message = $A.get('$Label.c.PP_VisitReminderUpdated');
            //message = successToastArray[3].trim();//Visit reminder updated.
        }
        return message;
    },

    doValidateReminder: function (component) {
        var reminderValid = component.find('reminderDate');
        var isReminderValid = true;
        if (!$A.util.isUndefinedOrNull(reminderValid)) {
            //reminderValid.reportValidity();
            isReminderValid = [].concat(reminderValid).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }
        return isReminderValid;
    },
    doValidateDueDate: function (component, helper) {
        var fieldValid = component.find('field');
        var isFieldValid = true;
        if (!$A.util.isUndefinedOrNull(fieldValid)) {
            fieldValid.reportValidity();
            isFieldValid = fieldValid.checkValidity();
            if (isFieldValid)
                component.set(
                    'v.dayAfterDueDate',
                    helper.addADay(component, fieldValid.get('v.value'))
                );
        }
        return isFieldValid;
    }
});
