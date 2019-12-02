/**
 * Created by Igor Malyuta on 01.03.2019.
 */
({
    doInit: function (component, event, helper) {
        //var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        var wrapper = component.get('v.wrapper');
        var todayDate = component.get('v.wrapper.nowDate');
        component.set('v.todayDate', todayDate);

        component.set('v.wrapper.task.Visible_For__c', 'Owner;Delegates');//Def value, if not selected


        component.set('v.priorities', wrapper.priorities);
        component.set('v.visibility', wrapper.visibility);
    },

    doCheckFields: function (component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValid', allValid);
        component.get('v.parent').setValidity(allValid);
    },

    onDaysChange: function (component, event, helper) {
        var startDate = component.get('v.wrapper.task.Start_Date__c');
        var dueDate = component.get('v.wrapper.task.ActivityDate');
        var reminderDate = component.get('v.wrapper.task.ReminderDateTime');
        var useDaysNumber = component.get('v.showNumbersAdd') === 'true';

        if (startDate && !dueDate) {
            if (reminderDate && moment(reminderDate, 'YYYY-MM-DD').isBefore(startDate)) {
                component.set('v.wrapper.task.ReminderDateTime', startDate);
            }
        }

        if (!startDate || !dueDate) {
            component.set('v.showNumbersAdd', false);
            component.set('v.dayRemind', 0);
            return;
        }

        dueDate = moment(dueDate, 'YYYY-MM-DD');

        if (useDaysNumber) {
            var daysCount = component.get('v.dayRemind');
            var daysBetween = dueDate.diff(startDate, 'days');

            if (daysCount > daysBetween) {
                component.set('v.dayRemind', daysBetween);
                return;
            } else if (daysCount < 0) {
                component.set('v.dayRemind', 0);
                return;
            }

            var remDate = dueDate.add(-daysCount, 'days');
            component.set('v.wrapper.task.ReminderDateTime', remDate.format('YYYY-MM-DD'));

        } else {
            var remindDate = component.get('v.wrapper.task.ReminderDateTime');
            if (!remindDate) return;
            remindDate = moment(remindDate, 'YYYY-MM-DD');

            var diff = dueDate.diff(remindDate, 'days');
            if (diff < 0) {
                component.set('v.wrapper.task.ReminderDateTime', dueDate.format('YYYY-MM-DD'));
                diff = 0;
            }

            component.set('v.dayRemind', diff);
        }
    },

    dueNumberKeyPress: function (component, event, helper) {
        //Fired on press any key in field
        if (event.which === 13) helper.setDays(component);
    }
});