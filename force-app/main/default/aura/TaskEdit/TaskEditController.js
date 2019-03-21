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
                if (task.Status === 'Completed') {
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

        communityService.executeAction(component, 'checkEmailPreferencesIsOn', {}, function (on) {
            component.set('v.emailTurnedOn', on);
        });

        $A.createComponent(
            "aura:unescapedHtml",
            {
                value: 'You currently do not have your communication preferences set to receive email.  ' +
                    'Please <a href="settings?tab=account-settings" target="_blank">click</a> here to set your communications preferences in your account settings.'
            },
            function(compo) {
                var container = component.find("emailPreferencesPopup");
                if (container.isValid()) {
                    var body = container.get("v.body");
                    body.push(compo);
                    container.set("v.body", body);
                }
            }
        );
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

        communityService.executeAction(component, 'checkEmailPreferencesIsOn', {}, function (on) {
            component.set('v.emailTurnedOn', on);
            if (on === false) {
                component.find('emailPreferencesPopup').show();
            } else {
                component.find('spinner').show();
                communityService.executeAction(component, 'upsertTask', {
                    "paramTask": component.get('v.task')
                }, function () {
                    window.history.go(-1);
                }, null, function () {
                    component.find('spinner').hide();
                })
            }
        });
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
        var dueDate = component.get('v.task.ActivityDate');
        var reminderDateComponent = component.find("reminderDateId");

        if (freq === 'Complete By Date') {
            reminderDateComponent.set('v.value', dueDate);
            reminderDateComponent.set('v.disabled', true);
            $A.util.removeClass(reminderDateComponent, "slds-hide");
        } else if (freq === '1 day before') {
            // var d = new Date(dueDate);
            // let oneDay = d.setDate(d.getDate() - 1);
            // oneDay = new Date(oneDay).toISOString();
            // reminderDateComponent.set('v.disabled', false);
            // reminderDateComponent.set('v.value', oneDay);

            $A.util.toggleClass(reminderDateComponent, "slds-hide");
        }
    },
    onChangeSetReminder: function (component, event, helper) {
        var reminderFrequencyValue = event.getSource().get("v.value");
        var reminderDateComponent = component.find("reminderDateId");
        var reminderFrequencyComponent = component.find("reminderFreqId");

        if (reminderFrequencyValue === 'Disabled') {
            reminderFrequencyComponent.set('v.disabled', true);
            reminderDateComponent.set('v.disabled', true);
        } else if (reminderFrequencyValue === 'Email') {
            reminderFrequencyComponent.set('v.disabled', false);
            reminderDateComponent.set('v.disabled', false);
        }
    },
    onChangeDueDate: function (component, event, helper) {
        var dueDate = component.get('v.task.ActivityDate');
        var reminderFrequencyComponent = component.find("reminderFreqId");
        var reminderDateComponent = component.find("reminderDateId");

        if (reminderFrequencyComponent.get('v.value') === 'Complete By Date') {
            reminderDateComponent.set('v.value', dueDate);
        }
    }
});