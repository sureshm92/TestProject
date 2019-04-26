/**
 * Created by Igor Malyuta on 01.03.2019.
 */
({
    doInit: function (component, event, helper) {
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

    dueNumberKeyPress: function (component, event, helper) {
        //Fired on press any key in field
        if (event.which == 13)
            helper.setDays(component);
    },

    onRemindDaysChange: function (component, event, helper) {
        //Remove leading zero in field
        var days = component.get('v.dayRemind');
        if(!days) days = '0';

        days = days.toString().replace('^0+', '');
        var intDays = parseInt(days);
        var isNumberInput = component.get('v.showNumbersAdd') === 'true';

        communityService.executeAction(component, 'remindDateCalc', {
            'activityDate': component.get('v.task.ActivityDate'),
            'remindDate': component.get('v.task.Reminder_Date__c'),
            'isNumberInput': isNumberInput,
            'count': intDays
        }, function (response) {
            var date = JSON.parse(response);
            if(isNumberInput) {
                debugger;
                component.set('v.task.Reminder_Date__c', date);
            }
            else {
                debugger;
                component.set('v.dayRemind', date);
            }
        });
    },

    dateValid: function (component, event, helper) {
        var startDate = component.get('v.task.Start_Date__c');
        if (!startDate) return;

        var dueDate = component.get('v.task.ActivityDate');
        if (!dueDate) dueDate = startDate;

        communityService.executeAction(component, 'checkAndGetValidDate', {
            'start': startDate,
            'due': dueDate
        }, function (response) {
            component.set('v.task.ActivityDate', response);
        });
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