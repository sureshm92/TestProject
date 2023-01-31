({
    doInit: function (component, event, helper) {
        //component.find('spinner').show();
        var fields = ['Subject'];
        var sObj = { sobjectType: 'Task' };
        communityService.executeAction(
            component,
            'getMaxLength',
            {
                so: JSON.stringify(sObj),
                fieldNames: fields
            },
            function (returnValue) {
                component.set('v.maxLengthData', returnValue);
            }
        );

        component.set('v.reRender', true);
        communityService.executeValidParams = false;
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
        communityService.executeAction(
            component,
            'getisTravelSupportEnabled',
            {},
            function (returnValue) {
                component.set('v.isTravelSupportEnabled', returnValue);
                console.log('ret-->' + returnValue);
            },
            null,
            function () {}
        );

        //this.reRender = true;
        //Take scroll bar to top next time when the popup is displayed
        //if (!component.get('v.isReminderOnly')) {
        document.getElementsByClassName('with-scroll')[0].scrollTop = 0;
        //}
    },
    hasVendors: function (component, event, helper) {
        component.set('v.showVendors', event.detail.showVendors);
    },
    doCancel: function (component, event, helper) {
        helper.hideModal(component);
        component.set('v.reRender', false);
    },

    doSave: function (component, event, helper) {
        // check if task not null and type = visits, then delete task
        communityService.executeValidParams = false;
        var task = component.get('v.task');
        var visitDate = component.get('v.visitData.visitDate');
        var patientVisit = {
            sobjectType: 'Patient_Visit__c',
            Id: component.get('v.visitData.visit.Id'),
            Planned_Date__c: visitDate,
            Status__c: 'Scheduled'
        };
        var isTaskTab = component.get('v.isTaskTab') == true;
        var reminderDate = component.get('v.initData.reminderDate');
        var dueDateOrplanDate = !isTaskTab
            ? component.get('v.visitData.visitDate')
            : component.get('v.initData.activityDate');
        var emailPeferenceSelected = component.get('v.task.Remind_Using_Email__c');
        var smsPeferenceSelected = component.get('v.task.Remind_Using_SMS__c');
        var emailOptIn = component.get('v.emailOptIn');
        var smsOptIn = component.get('v.smsOptIn');
        var reminderOption = component.get('v.task.Remind_Me__c');
        var deleteVisitTask = component.get('v.deleteVisitReminder');
        var clearTask = component.get('v.task.clearReminderValue');
        if (new Date(dueDateOrplanDate) < new Date()) {
            communityService.showErrorToast('', $A.get('$Label.c.PP_ReminderUnderFlowError'), 3000);
            return;
        }
        if (
            !$A.util.isUndefinedOrNull(reminderOption) &&
            !(smsOptIn && smsPeferenceSelected) &&
            !(emailOptIn && emailPeferenceSelected) &&
            !deleteVisitTask &&
            !clearTask
        ) {
            communityService.showErrorToast('', $A.get('$Label.c.PP_Remind_Using_Required'), 3000);
            return;
        }
        if (task.Task_Type__c == 'Visit') {
            if (deleteVisitTask) {
                communityService.executeAction(
                    component,
                    'deleteReminder',
                    {
                        taskId: component.get('v.taskId')
                    },
                    function (returnValue) {
                        if (returnValue) {
                            component.set('v.isSaveOperation', true);
                            communityService.showSuccessToast('', message, 3000);
                            helper.hideModal(component);
                            component.find('spinner').hide();
                        }
                    },
                    null,
                    function () {}
                );
            }

            communityService.executeAction(
                component,
                'updatePatientVisits',
                {
                    visit: JSON.stringify(patientVisit)
                },
                function (returnValue) {
                    if (!reminderOption) {
                        component.set('v.isSaveOperation', true);
                        communityService.showSuccessToast('', message, 3000);
                        helper.hideModal(component);
                        component.find('spinner').hide();
                    }
                },
                null,
                function () {}
            );
        }
        task.Task_Type__c =
            $A.util.isEmpty(task.Task_Type__c) && !component.get('v.initData.createdByAdmin')
                ? 'Not Selected'
                : task.Task_Type__c;
        var reminderDate = component.get('v.initData.reminderDate');
        if (reminderOption === 'Custom') {
            if (new Date(reminderDate) < new Date()) {
                communityService.showErrorToast(
                    '',
                    $A.get('$Label.c.PP_ReminderUnderFlowError'),
                    3000
                );
                return;
            }
        }
        if (!task.Subject) {
            communityService.showErrorToast('', $A.get('$Label.c.Empty_TaskName'), 3000);
            return;
        }
        if (
            (!$A.util.isUndefinedOrNull(reminderDate) ||
                !$A.util.isUndefinedOrNull(reminderOption)) &&
            !(smsPeferenceSelected && smsOptIn) &&
            !(emailPeferenceSelected && emailOptIn) &&
            !deleteVisitTask &&
            !clearTask
        ) {
            communityService.showErrorToast('', $A.get('$Label.c.PP_Remind_Using_Required'), 3000);
            return;
        }
        var isValidFields = true;
        if (!component.get('v.initData.createdByAdmin')) {
            isValidFields =
                helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component);
        }
        if (!component.get('v.isValidFields') || !isValidFields) {
            var showToast = true;
            if (!component.get('v.isNewTask')) {
                if (
                    component.get('v.jsonState') ===
                    JSON.stringify(component.get('v.initData')) + '' + JSON.stringify(task)
                ) {
                    showToast = false;
                }
            }
            if (showToast) {
                communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'), 3000);
                return;
            }
        }
        var message = helper.setSuccessToast(component);
        component.find('spinner').show();
        if (task.Task_Type__c == 'Visit') {
            component.set('v.initData.activityDate', visitDate);
        }
        if ((reminderOption || task.Task_Type__c != 'Visit') && !deleteVisitTask) {
            communityService.executeAction(
                component,
                'upsertTask',
                {
                    wrapper: JSON.stringify(component.get('v.initData')),
                    paramTask: JSON.stringify(task),
                    isNewTaskFromTaskTab: component.get('v.isNewTask') && isTaskTab ? true : false
                },
                function () {
                    component.set('v.isSaveOperation', true);
                    component.find('spinner').hide();
                    communityService.showSuccessToast('', message, 3000);
                    helper.hideModal(component);
                },
                function () {
                    component.find('spinner').hide();
                },
                null
            );
        }
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
        console.log('isTaskTab-->' + component.get('v.isTaskTab'));
        var remindMe = component.get('v.task.Remind_Me__c');
        var isTaskTab = component.get('v.isTaskTab') == true;
        var isReminderOnly = component.get('v.isReminderOnly');
        var reminderOptionValid = !isTaskTab
            ? component.find('reminderOption')
            : !isReminderOnly
            ? component.find('taskReminderOption')
            : component.find('taskReminderOption1');
        var isGreaterThanToday = false;
        var dueDateOrplanDate = !isTaskTab
            ? component.get('v.visitData.visitDate')
            : component.get('v.initData.activityDate');
        var today = moment();
        var task = component.get('v.task');
        //component.set('v.initData.activityDate',new Date(new Date(component.get('v.initData.activityDate')) - (-(3600 *1000))));
        //console.log(component.get('v.initData.activityDate'));
        component.set('v.initData.today', new Date(new Date() + 60 * 1000));

        if (remindMe !== 'Custom') {
            if (remindMe && remindMe.toUpperCase() === '1 Week before'.toUpperCase()) {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today);
            } else if (remindMe === '1 day before') {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today);
            } else if (remindMe === '1 hour before') {
                var reminderdate = new Date(dueDateOrplanDate) - 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            } else if (remindMe === '4 hours before') {
                var reminderdate = new Date(dueDateOrplanDate) - 4 * 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            }
            if (remindMe === 'No reminder' && task.Task_Type__c === 'Visit') {
                component.set('v.initData.reminderDate', null);
                component.set('v.deleteVisitReminder', true);
                component.set('v.task.Remind_Using_Email__c', false);
                component.set('v.task.Remind_Using_SMS__c', false);
                component.set('v.task.clearReminderValue', true);
            } else if (remindMe === 'No reminder') {
                component.set('v.initData.reminderDate', null);
                component.set('v.deleteVisitReminder', false);
                component.set('v.task.Remind_Using_Email__c', false);
                component.set('v.task.Remind_Using_SMS__c', false);
                component.set('v.task.clearReminderValue', true);
            }
            if (isGreaterThanToday) {
                if (!$A.util.isUndefinedOrNull(reminderOptionValid)) {
                    reminderOptionValid.setCustomValidity(
                        $A.get('$Label.c.PP_Reminder_Error_Message')
                    );
                    reminderOptionValid.reportValidity();
                }
                if (isReminderOnly && !component.get('v.initData.createdByAdmin')) {
                    component.set('v.isValidFields', false);
                }
            } else {
                if (!$A.util.isUndefinedOrNull(reminderOptionValid)) {
                    reminderOptionValid.setCustomValidity('');
                    reminderOptionValid.reportValidity();
                    if (isReminderOnly && !component.get('v.initData.createdByAdmin')) {
                        if (helper.doValidateReminder(component) === true) {
                            component.set('v.isValidFields', true);
                        } else {
                            component.set('v.isValidFields', false);
                        }
                    }
                }
            }
        } else {
            if (!component.get('v.initData.createdByAdmin')) {
                if (isReminderOnly) {
                    if (helper.doValidateReminder(component) === true) {
                        component.set('v.isValidFields', true);
                    } else {
                        component.set('v.isValidFields', false);
                    }
                }
                if (!$A.util.isUndefinedOrNull(reminderOptionValid)) {
                    reminderOptionValid.setCustomValidity('');
                    reminderOptionValid.reportValidity();
                }
            } else {
                if (
                    ($A.util.isUndefinedOrNull(component.get('v.initData.reminderDate')) &&
                        remindMe !== 'No reminder') ||
                    helper.doValidateReminder(component) === false
                ) {
                    component.set('v.isValidFields', false);
                } else {
                    component.set('v.isValidFields', true);
                }
            }
        }

        if (isTaskTab) {
            var taskName = component.find('taskName');
            if (taskName) {
                if ($A.util.isUndefinedOrNull(component.get('v.task.Subject'))) {
                    taskName.setCustomValidity($A.get('$Label.c.PP_RequiredErrorMessage'));
                    taskName.reportValidity();
                } else {
                    taskName.setCustomValidity('');
                    taskName.reportValidity();
                }
            }
        }
        if (remindMe === 'No reminder') {
            component.set('v.isValidFields', true);
        }
        var isValidFields =
            helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component);
        //component.set('v.isValidFields', isValidFields);
        console.log(
            'inside condition-->' +
                ($A.util.isUndefinedOrNull(dueDateOrplanDate) ||
                    isGreaterThanToday ||
                    $A.util.isUndefinedOrNull(
                        component.get('v.initData.reminderDate') || !isValidFields
                    ))
        );

        if (
            component.get('v.initData.createdByAdmin') &&
            $A.util.isUndefinedOrNull(component.get('v.initData.activityDate'))
        ) {
            if (
                !isValidFields ||
                ($A.util.isUndefinedOrNull(component.get('v.initData.reminderDate')) &&
                    remindMe === 'Custom')
            ) {
                component.set('v.isValidFields', false);
            } else {
                component.set('v.isValidFields', true);
            }
        } else if (
            $A.util.isUndefinedOrNull(dueDateOrplanDate) ||
            isGreaterThanToday ||
            !isValidFields ||
            ($A.util.isUndefinedOrNull(component.get('v.initData.reminderDate')) &&
                remindMe === 'Custom')
        ) {
            component.set('v.isValidFields', false);
        } else {
            component.set('v.isValidFields', true);
        }
    },

    doNavigateToAccountSettings: function (component, event, helper) {
        sessionStorage.setItem('Cookies', 'Accepted');
        window.open('account-settings?communication-preferences', '_blank');
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
    },
    doValidateReminderFrequency: function (component, helper) {
        /* var remindMe = component.get('v.task.Remind_Me__c');
        var task = component.get('v.task');
        var reminderOptionValid = task.Task_Type__c == 'Visit'? component.find('reminderOption'):component.find('taskReminderOption');
        var isGreaterThanToday = false;
        var dueDateOrplanDate = task.Task_Type__c == 'Visit'?component.get('v.visitData.visitDate'):component.get('v.initData.activityDate');
        var today = moment();
         if(remindMe !== 'Custom'){
         if(remindMe === '1 Week before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today)
         }else if(remindMe === '1 day before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today)
         }else if(remindMe === '1 hour before'){
             var reminderdate = new Date(dueDateOrplanDate) - (3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }else if(remindMe === '4 hours before'){
             var reminderdate = new Date(dueDateOrplanDate) - (4*3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }
         if(isGreaterThanToday){
               reminderOptionValid.setCustomValidity('Reminder Date cannot be in the past');
               reminderOptionValid.reportValidity();
         }else{
             reminderOptionValid.setCustomValidity(' ');
             reminderOptionValid.reportValidity();
         }
         }
        
      // var isValidFields = helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component) ;
       //component.set('v.isValidFields', isValidFields);
       if($A.util.isUndefinedOrNull(dueDateOrplanDate) || isGreaterThanToday || component.get('v.isValidFields') == false){
                   component.set('v.isValidFields', false);
        }
       else{
                  component.set('v.isValidFields', true);
           }*/
    }
});
