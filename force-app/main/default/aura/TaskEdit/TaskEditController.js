/**
 * Created by mkotenev on 3/4/2019.
 */
({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        component.set('v.task', {
            sobjectType: 'Task'
        });
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
            component.set('v.task', wrapper.task);
            if (wrapper.task.Status === 'Completed') {
                component.set('v.taskStatusCompleted', true);
            }
            component.set('v.isDelegate', wrapper.isDelegate);
            component.set('v.hasDelegates', wrapper.hasDelegates);
            component.set('v.emailDelegateTurnedOn', wrapper.emailPreferencesDelegateIsOn);
            component.set('v.emailParticipantTurnedOn', wrapper.emailPreferencesParticipantIsOn);
            if (!wrapper.emailPreferencesIsOn  && (!wrapper.emailPreferencesDelegateIsOn && wrapper.hasDelegates)) {
                var reminderDateComponent = component.find('reminderDateId');
                var reminderFrequencyComponent = component.find('reminderFreqId');
                reminderFrequencyComponent.set('v.disabled', true);
                reminderDateComponent.set('v.disabled', true);
            }
            component.set('v.taskTypeList', wrapper.taskTypeList);
            component.find('spinner').hide();
        });
        if (paramTaskId) {
            component.set('v.editMode', true);
        } else {
            component.set('v.editMode', false);
            component.set('v.tascomponent.findk.Status', 'Open');
        }
        if(!component.get('v.task.ActivityDate')){
            var reminderFrequencyComponent = component.find('reminderFreqId');
            reminderFrequencyComponent.set('v.disabled', true);
            reminderFrequencyComponent.set('v.value', $A.get('$Label.c.Complete_By_Date'));
        }
    },

    doCancel: function (component, event, helper) {
        component.find('spinner').show();
        window.history.go(-1);
    },

    doSave: function (component, event, helper) {
        var task = component.get('v.task');
        if (!task.Subject) {
            communityService.showErrorToast('', 'Task Name cannot be empty');
            return;
        }

        communityService.executeAction(component, 'checkEmailPreferencesIsOn', {}, function () {
            component.find('spinner').show();
            communityService.executeAction(component, 'upsertTask', {
                'paramTask': component.get('v.task')
            }, function () {
                window.history.go(-1);
            }, null, function () {
                component.find('spinner').hide();
            })
        });
    },

    doDeleteTask: function (component, event, helper) {
        communityService.executeAction(component, 'deleteTask', {
            'paramTask': component.get('v.task')
        }, function (string) {
            window.history.go(-1);
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
        var reminderDateComponent = component.find('reminderDateId');

        if (freq == $A.get('$Label.c.Complete_By_Date')) {
            reminderDateComponent.set('v.disabled', false);
        } else if (freq == $A.get('$Label.c.One_day_before')) {
            var reminderDateComponent = component.find('reminderDateId');
            var dueDate = component.get('v.task.ActivityDate');
            var d = new Date(dueDate);
            const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            var formatedDate = monthNames[d.getMonth()] + ' ' + (d.getDate() - 1) + ',' + d.getFullYear();
            reminderDateComponent.set('v.value', formatedDate);
            reminderDateComponent.set('v.disabled', true);
        }
    },
    onChangeSetReminder: function (component, event, helper) {
        var reminderFrequencyValue = event.getSource().get('v.value');
        var reminderDateComponent = component.find('reminderDateId');
        var reminderFrequencyComponent = component.find('reminderFreqId');
        if (reminderFrequencyValue == $A.get('$Label.c.Disabled')) {
            reminderFrequencyComponent.set('v.disabled', true);
            reminderDateComponent.set('v.disabled', true);
            reminderDateComponent.set('v.value', '');
        } else if (reminderFrequencyValue == $A.get('$Label.c.Email')) {
            if(component.get('v.task.ActivityDate')) {
                reminderFrequencyComponent.set('v.disabled', false);
            }
            reminderDateComponent.set('v.disabled', false);
        }
    },
    onChangeDueDate: function (component, event, helper) {
        var dueDate = component.get('v.task.ActivityDate');
        var reminderFrequencyComponent = component.find('reminderFreqId');
        var reminderDateComponent = component.find('reminderDateId');
        if(component.get('v.emailParticipantTurnedOn') && component.find('reminderOptionsId').get('v.value') == $A.get('$Label.c.Email')){
            if(dueDate) {
                reminderFrequencyComponent.set('v.disabled', false);
            } else {
                reminderFrequencyComponent.set('v.value', $A.get('$Label.c.Complete_By_Date'));
                reminderFrequencyComponent.set('v.disabled', true);
                reminderDateComponent.set('v.disabled', false);
            }
        }
        if (reminderFrequencyComponent.get('v.value') == $A.get('$Label.c.Complete_By_Date')) {
            reminderDateComponent.set('v.value', dueDate);
        }
    }
});