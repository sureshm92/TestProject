/**
 * Created by Igor Malyuta on 01.03.2019.
 */
({
    doInit: function (component, event, helper) {
        let wrapper = component.get('v.wrapper');
        component.set('v.todayDate', component.get('v.wrapper.nowDate'));
        component.set('v.priorities', wrapper.priorities);
        component.set('v.visibility', wrapper.visibility);
    },

    doCheckFields: function (component, event, helper) {
        let allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValid', allValid);
        component.get('v.parent').setValidity(allValid);
    },

    onDaysChange: function (component, event, helper) {
        let startDate = component.get('v.taskConfig.startDate');
        let dueDate = component.get('v.taskConfig.endTime');
        let reminderDate = component.get('v.taskConfig.reminderDate');
        let useDaysNumber = component.get('v.showNumbersAdd') === 'true';

        if (startDate && !dueDate) {
            if (reminderDate && moment(reminderDate, 'YYYY-MM-DD').isBefore(startDate)) {
                component.set('v.taskConfig.reminderDate', startDate);
            }
        }

        if (!startDate || !dueDate) {
            component.set('v.showNumbersAdd', false);
            component.set('v.dayRemind', 0);
            return;
        }

        dueDate = moment(dueDate, 'YYYY-MM-DD');

        if (useDaysNumber) {
            let daysCount = component.get('v.dayRemind');
            let daysBetween = dueDate.diff(startDate, 'days');

            if (daysCount > daysBetween) {
                component.set('v.dayRemind', daysBetween);
                return;
            } else if (daysCount < 0) {
                component.set('v.dayRemind', 0);
                return;
            }

            let remDate = dueDate.add(-daysCount, 'days');
            component.set('v.taskConfig.reminderDate', remDate.format('YYYY-MM-DD'));

        } else {
            let remindDate = component.get('v.taskConfig.reminderDate');
            if (!remindDate) return;
            remindDate = moment(remindDate, 'YYYY-MM-DD');

            let diff = dueDate.diff(remindDate, 'days');
            if (diff < 0) {
                component.set('v.taskConfig.reminderDate', dueDate.format('YYYY-MM-DD'));
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