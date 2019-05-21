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

    doCheckFields: function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        component.set('v.isValidFields', allValid);
    },

    onDaysChange: function (component, event, helper) {
        var startDate = component.get('v.task.Start_Date__c');
        if (!startDate) return;

        var dueDate = component.get('v.task.ActivityDate');
        if(!dueDate) {
            component.set('v.showNumbersAdd', 'false');
            return;
        }

        startDate = new Date(startDate);
        startDate.setUTCHours(12);
        dueDate = new Date(dueDate);
        dueDate.setUTCHours(12);

        // if(component.get('v.showNumbersAdd') === 'true') {
            var days = component.get('v.dayRemind');
            var daysBetween = helper.getDaysBetween(component, startDate, dueDate);

            if(!days || days > daysBetween) {
                days = 1;
                component.set('v.dayRemind', days);
            }

            //Remove leading zero in field
            days = days.toString().replace('^0+', '');

            var remindDate = component.get('v.task.Reminder_Date__c');
            if(!remindDate) {
                remindDate = dueDate;
            }
            else {
                remindDate = new Date(remindDate);
                remindDate.setUTCHours(12);
            }
            remindDate = remindDate.setDate(dueDate.getDate() - parseInt(days));
            component.set('v.task.Reminder_Date__c',
                $A.localizationService.formatDate(remindDate, 'YYYY-MM-DD'));
        // }
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