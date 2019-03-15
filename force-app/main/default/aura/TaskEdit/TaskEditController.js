/**
 * Created by mkotenev on 3/4/2019.
 */
({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.todayDate', todayDate);
        component.set('v.task', {
            sobjectType: 'Task'
        });
        var paramTaskId = communityService.getUrlParameter('id');
        if (paramTaskId) {
            component.set('v.editMode', true);
            component.set('v.pageTitle', $A.get('$Label.c.TTL_Edit_Task'));

            communityService.executeAction(component, 'getTaskById', {
                "taskId": paramTaskId
            }, function (task) {
                component.set('v.task', task);
                component.set('v.initialized', true);
                if(task.Status === 'Completed') {
                    component.set('v.taskStatusCompleted', true);
                }
            }, null, function () {
                component.find('spinner').hide();
            });

        } else {
            component.set('v.editMode', false);
            component.set('v.pageTitle', $A.get('$Label.c.TTL_Create_Task'));
            component.set('v.initialized', true);
            component.set('v.task.Status', 'Open');
            component.find('spinner').hide();
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
        component.find('spinner').show();
        communityService.executeAction(component, 'upsertTask', {
            "paramTask": component.get('v.task')
        }, function () {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doDeleteTask: function (component, event, helper) {
        communityService.executeAction(component, 'deleteTask', {
            "paramTask": component.get('v.task')
        }, function (string) {
            window.history.go(-1);
        })
    },

    doMarkAsCompleted: function (component, event, helper) {
        console.log('before, task: ' + component.get('v.task'));
        component.find('spinner').show();
        communityService.executeAction(component, 'markAsCompleted', {
            "paramTask": component.get('v.task')
        }, function (string) {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
    onChangeFreq: function (component, event, helper) {
        var freq = event.getSource().get("v.value");
        if (freq === 'Compete By Date') {
            component.find("reminderDateId").set('v.disabled', true);
        } else if (freq === '1 day before') {
            component.find("reminderDateId").set('v.disabled', false);
        }
    }
});