/**
 * Created by user on 01.03.2019.
 */
({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.task', initData.task);
            component.set('v.priorities', initData.priorities);
            component.set('v.visibility', initData.visibility);
            component.set('v.taskFilters', initData.filters);

            component.set('v.statuses', []);
        });
    },

    dueNumberKeyPress : function(component, event, helper) {
        //Fired on press any key in field
        if(event.which == 13)
            helper.setDays(component);
    },

    onRemindDaysChange : function(component, event, helper) {
        //Remove leading zero in field
        var days = component.get('v.dayRemind').toString().replace('^0+', '');
        var intDays = parseInt(days);
        component.set('v.dayRemind', intDays);

        communityService.executeAction(component, 'remindBeforeDays', {
            'dateDue' : component.get('v.task.ActivityDate'),
            'count' : intDays
        }, function (response) {
            component.set('v.dateRemind', response);
        });
    },

    dateValid : function(component, event, helper) {
        var startDate = component.get('v.task.Start_Date__c');
        var dueDate = component.get('v.task.ActivityDate');
        if(!startDate || !dueDate) {
            return;
        }

        communityService.executeAction(component, 'checkAndGetValidDate', {
            'start' : startDate,
            'due' : dueDate
        }, function (response) {
            component.set('v.task.ActivityDate', response);
        });
    },

    createTask : function (component, event, helper) {
        var filter = component.get('v.taskFilters');
        filter.statuses = component.get('v.statuses');

        component.find('spinner').show();
        communityService.executeAction(component, 'createTasks', {
            'task' : JSON.stringify(component.get('v.task')),
            'filter' : JSON.stringify(component.get('v.taskFilters'))
        }, function (response) {
            if(response > 0)
                communityService.showSuccessToast(
                    'Success!',
                    'Task successfully created for ' + response +  ' users.'
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

    resetClick : function (component, event, helper) {
        helper.reset(component);
    }
})