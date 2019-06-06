/**
 * Created by Igor Malyuta on 01.03.2019.
 */
({
    doInit: function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);

        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.task', initData.task);
            component.set('v.task.Visible_For__c', 'Owner;Delegates');//Def value, if not selected
            component.set('v.priorities', initData.priorities);
            component.set('v.visibility', initData.visibility);
            component.set('v.taskFilters', initData.filters);

            component.set('v.statuses', []);
        });
    },

    doCheckFields: function (component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            debugger;
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        component.set('v.isValidFields', allValid);
    },

    onDaysChange: function (component, event, helper) {
        component.checkFields();
        if(!component.get('v.isValidFields')) return;

        var startDate = component.get('v.task.Start_Date__c');
        var dueDate = component.get('v.task.ActivityDate');
        var useDaysNumber = component.get('v.showNumbersAdd') === 'true';

        if(startDate && !dueDate) {
            var reminderDate = component.get('v.task.Reminder_Date__c');
            if(reminderDate && moment(reminderDate).isBefore(startDate)) {
                component.set('v.task.Reminder_Date__c', startDate);
            }
        }

        if (!startDate || !dueDate) {
            component.set('v.dayRemind', 0);
            return;
        }

        dueDate = moment(dueDate, 'YYYY-MM-DD');

        if (useDaysNumber) {
            var daysCount = component.get('v.dayRemind');
            var daysBetween = dueDate.diff(startDate, 'days');

            if(daysCount > daysBetween) {
                component.set('v.dayRemind', daysBetween);
                return;
            } else if(daysCount < 0) {
                component.set('v.dayRemind', 0);
                return;
            }

            var remDate = dueDate.add(-daysCount, 'days');
            component.set('v.task.Reminder_Date__c', remDate.format('YYYY-MM-DD'));

        } else {
            var remindDate = component.get('v.task.Reminder_Date__c');
            if (!remindDate) return;
            remindDate = moment(remindDate, 'YYYY-MM-DD');

            var diff = dueDate.diff(remindDate, 'days');
            if(diff < 0) {
                component.set('v.task.Reminder_Date__c', dueDate.format('YYYY-MM-DD'));
                diff = 0;
            }

            component.set('v.dayRemind', diff);
        }
    },

    dueNumberKeyPress: function (component, event, helper) {
        //Fired on press any key in field
        if (event.which === 13) helper.setDays(component);
    },

    createTask: function (component, event, helper) {
        var filter = component.get('v.taskFilters');
        filter.statuses = component.get('v.statuses');

        component.find('spinner').show();
        communityService.executeAction(component, 'createTasks', {
            'task': JSON.stringify(component.get('v.task')),
            'filter': JSON.stringify(component.get('v.taskFilters'))
        }, function (response) {
            if (response > 0)
                communityService.showSuccessToast(
                    'Success!',
                    'Task successfully created for ' + response + ' users.'
                );
            else
                communityService.showWarningToast(
                    'Fail!',
                    'No relevant users found in the system'
                );
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    resetClick: function (component, event, helper) {
        helper.reset(component);
    }
})