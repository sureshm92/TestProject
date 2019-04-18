/**
 * Created by mkotenev on 3/4/2019.
 */
({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        if(!component.get('v.initialized')) {
            component.set('v.task', {
                sobjectType: 'Task'
            });
        }
        const reminderFrequencyList = [
            $A.get('$Label.c.One_day_before'),
            $A.get('$Label.c.Complete_By_Date')
        ];
        component.set('v.reminderFrequencyList',reminderFrequencyList);
        const setReminderValueList = [
            $A.get('$Label.c.Email'),
            $A.get('$Label.c.Disabled')
        ];
        component.set('v.setReminderValueList',setReminderValueList);
        var paramTaskId = communityService.getUrlParameter('id');
        if(paramTaskId == undefined){
            paramTaskId = null;
        }
        communityService.executeAction(component, 'getTaskEditData', {
            'taskId': paramTaskId
        }, function (wrapper) {
            debugger;
            if(!component.get('v.initialized')) {
                component.set('v.task', wrapper.task);
            }
            component.set('v.errorMessage', wrapper.errorMessage);
            component.set('v.reminderDateEnabled', wrapper.reminderEnabled);
            component.set('v.reminderEnabled', wrapper.reminderEnabled);
            if(wrapper.reminderEnabled && wrapper.task.ActivityDate && !component.get('v.initialized')){
                component.set('v.frequencyEnabled', true);
            }
            if(wrapper.reminderEnabled && component.find('dueDateInputId') && component.get('v.initialized')){
                component.set('v.frequencyEnabled', true);
            }
            if (wrapper.task.Status === 'Completed') {
                component.set('v.taskStatusCompleted', true);
            }
            component.set('v.isReferral', wrapper.isReferral);
            if(wrapper.isReferral){
                component.set('v.task.Task_Type__c', null);
            }
            if(!component.get('v.task.ActivityDate')){
                component.set('v.disableFrequency', true);
            }
            component.set('v.taskTypeList', wrapper.taskTypeList);
            if (paramTaskId) {
                component.set('v.editMode', true);
            } else {
                component.set('v.editMode', false);
                component.set('v.task.Status', 'Open');
            }
            component.find('spinner').hide();
            component.set('v.initialized', true);
        });
    },

    doCancel: function (component, event, helper) {
        component.find('spinner').show();
        window.history.go(-1);
    },

    doSave: function (component, event, helper) {
        component.set('v.task.Reminder_Date__c', new Date(component.get('v.task.Reminder_Date__c')));
        var task = component.get('v.task');
        if (!task.Subject) {
            communityService.showErrorToast('', 'Task Name cannot be empty');
            return;
        }
        component.find('spinner').show();
        communityService.executeAction(component, 'upsertTask', {
            'paramTask': component.get('v.task')
        }, function () {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doDeleteTask: function (component, event, helper) {
        communityService.executeAction(component, 'deleteTask', {
            'paramTask': component.get('v.task')
        }, function (string) {
            window.history.go(-1);
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

    onChangeFreq: function (component, event, helper) {
        var freq = event.getSource().get('v.value');

        if (freq == $A.get('$Label.c.Complete_By_Date')) {
            component.set('v.reminderDateEnabled', true);
        } else if (freq == $A.get('$Label.c.One_day_before')) {
            $A.enqueueAction(component.get('c.changeRemiderDate'));
            component.set('v.reminderDateEnabled', false);
        }
    },

    onChangeSetReminder: function (component, event, helper) {
        var reminderFrequencyValue = event.getSource().get('v.value');
        if (reminderFrequencyValue == $A.get('$Label.c.Disabled')) {
            component.set('v.frequencyEnabled', false);
            component.set('v.reminderDateEnabled', false);
            component.set('v.task.Reminder_Date__c', null);
        } else if (reminderFrequencyValue == $A.get('$Label.c.Email')) {
            if(component.get('v.task.ActivityDate')) {
                component.set('v.frequencyEnabled', true);
            }
            component.set('v.reminderDateEnabled', true);
        }
    },

    onChangeDueDate: function (component, event, helper) {
        var dueDate = component.get('v.task.ActivityDate');
        var reminderFrequencyComponent = component.find('reminderFreqId');
        var reminderDateComponent = component.find('reminderDateId');
        if(!dueDate) component.set('v.frequencyEnabled', false);
        if (component.find('reminderOptionsId').get('v.value') == $A.get('$Label.c.Email')) {
            component.get('v.reminderDateEnabled')
            if (dueDate) {
                if (reminderFrequencyComponent.get('v.value') == $A.get('$Label.c.One_day_before')){
                    $A.enqueueAction(component.get('c.changeRemiderDate'));
                }
                component.set('v.frequencyEnabled', true);
            } else {
                reminderFrequencyComponent.set('v.value', $A.get('$Label.c.Complete_By_Date'));
                component.set('v.task.Reminder_Date__c', dueDate);
            }
        }
        if(dueDate) component.set('v.frequencyEnabled', true);
    },

    changeRemiderDate: function (component, event, helper) {
        var dueDate = component.get('v.task.ActivityDate');
        var d = new Date(dueDate);
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        var formatedDate = monthNames[d.getMonth()] + ' ' + (d.getDate() - 1) + ',' + d.getFullYear();
        component.set('v.task.Reminder_Date__c', formatedDate);
    }
});