/**
 * Created by mkotenev on 3/4/2019.
 * Refactored by Igor Malyuta
 */
({
    doInit: function (component, event, helper) {
        var paramTaskId = communityService.getUrlParameter('id');
        if (paramTaskId === undefined) paramTaskId = null;

        if (!communityService.isDummy()) {
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'getTaskEditData',
                {
                    taskId: paramTaskId
                },
                function (wrapper) {
                    component.set('v.initData', wrapper);
                    component.set('v.isEnrolled', wrapper.isEnrolled);
                    component.set('v.reminderEnabled', wrapper.reminderEnabled);

                    if (wrapper.reminderEnabled) {
                        if (wrapper.reminderDate) {
                            component.set('v.reminderSetMode', 'Email');
                            component.set('v.reminderDateEnabled', true);
                            if (wrapper.activityDate) component.set('v.frequencyEnabled', true);
                        } else {
                            component.set('v.reminderSetMode', 'Disabled');
                        }
                    }

                    component.set('v.taskTypeList', wrapper.taskTypeList);

                    var task = wrapper.task;
                    if (paramTaskId) {
                        component.set('v.editMode', true);

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
                        component.set('v.editAvailable', isOwner && task.Status !== 'Completed');
                    } else {
                        component.set('v.editMode', false);
                        component.set('v.editAvailable', true);

                        task.Status = 'Open';
                        task.Task_Type__c = 'Not Selected';
                    }
                    component.set('v.task', task);

                    var visitId = communityService.getUrlParameter('visitId');
                    if (visitId) component.set('v.task.Patient_Visit__c', visitId);

                    component.set(
                        'v.jsonState',
                        JSON.stringify(wrapper) + '' + JSON.stringify(task)
                    );
                    component.set('v.isValidFields', true);
                    component.find('spinner').hide();
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doCancel: function (component, event, helper) {
        component.find('spinner').show();
        window.history.go(-1);
    },

    doSave: function (component, event, helper) {
        var task = component.get('v.task');
        if (!task.Subject) {
            communityService.showErrorToast('', $A.get('$Label.c.Empty_TaskName'));
            return;
        }

        var reminderDate = component.get('v.initData.reminderDate');
        var reminderMode = component.get('v.reminderSetMode');
        if (component.get('v.reminderDateEnabled') && reminderMode === 'Email') {
            if (!reminderDate) {
                communityService.showErrorToast('', $A.get('$Label.c.Empty_Reminder'));
                return;
            }
        }

        if (!component.get('v.isValidFields')) {
            var showToast = true;
            if (component.get('v.editMode')) {
                if (
                    component.get('v.jsonState') ===
                    JSON.stringify(component.get('v.initData')) + '' + JSON.stringify(task)
                ) {
                    showToast = false;
                }
            }
            if (showToast) {
                communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'));
                return;
            }
        }

        component.find('spinner').show();
        communityService.executeAction(
            component,
            'upsertTask',
            {
                wrapper: JSON.stringify(component.get('v.initData')),
                paramTask: JSON.stringify(task),
                false
            },
            function () {
                window.history.go(-1);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },

    doMarkAsCompleted: function (component, event, helper) {
        helper.updateStatus(component, 'markAsCompleted');
    },

    doIgnoreTask: function (component, event, helper) {
        helper.updateStatus(component, 'ignoreTask');
    },

    onChangeFreq: function (component, event, helper) {
        var freq = component.get('v.frequencyMode');
        if (freq === 'By_Date') {
            component.set('v.initData.reminderDate', component.get('v.initData.activityDate'));
            component.set('v.reminderDateEnabled', true);
        } else if (freq === 'Day_Before') {
            $A.enqueueAction(component.get('c.setOneDayBefore'));
            component.set('v.reminderDateEnabled', false);
        }
    },

    onChangeSetReminder: function (component, event, helper) {
        var reminderSetMode = component.get('v.reminderSetMode');

        if (reminderSetMode === 'Disabled') {
            component.set('v.frequencyMode', 'By_Date');
            component.set('v.frequencyEnabled', false);
            component.set('v.reminderDateEnabled', false);
            component.set('v.initData.reminderDate', null);
        } else if (reminderSetMode === 'Email') {
            var dueDate = component.get('v.initData.activityDate');
            if (dueDate && component.get('v.isValidFields'))
                component.set('v.frequencyEnabled', true);
            component.set('v.reminderDateEnabled', true);
        }
    },

    onChangeDueDate: function (component, event, helper) {
        var dueDate = component.get('v.initData.activityDate');
        var frequencyMode = component.get('v.frequencyMode');
        var reminderSetMode = component.get('v.reminderSetMode');

        if (!dueDate) {
            component.set('v.frequencyEnabled', false);
            if (component.get('v.reminderEnabled')) component.set('v.reminderDateEnabled', true);
        }

        if (reminderSetMode === 'Email') {
            if (dueDate && !helper.isSameDay(component)) {
                component.set('v.frequencyEnabled', true);
                component.set('v.initData.reminderDate', dueDate);
                if (frequencyMode === 'Day_Before')
                    $A.enqueueAction(component.get('c.setOneDayBefore'));
            } else {
                component.set('v.frequencyMode', 'By_Date');
                component.set('v.frequencyEnabled', false);
                component.set('v.initData.reminderDate', dueDate);
            }
        } else {
            component.set('v.reminderDateEnabled', false);
            component.set('v.frequencyEnabled', false);
        }
    },

    setOneDayBefore: function (component, event, helper) {
        if (!helper.isSameDay(component)) {
            var dueDate = moment(component.get('v.initData.activityDate'), 'YYYY-MM-DD');
            dueDate.subtract(1, 'days');
            component.set('v.initData.reminderDate', dueDate.format('YYYY-MM-DD'));
        }
    },

    doCheckFields: function (component, event, helper) {
        if (component.get('v.initData') && component.get('v.initData.createdByAdmin')) return;

        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValidFields', allValid);
    }
});
