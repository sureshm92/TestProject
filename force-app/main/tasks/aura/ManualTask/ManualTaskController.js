/**
 * Created by Igor Malyuta on 01.03.2019.
 */
({
    doInit: function(component, event, helper) {
        let wrapper = component.get('v.wrapper');
        component.set('v.todayDate', component.get('v.wrapper.nowDate'));
        component.set('v.priorities', wrapper.priorities);
        component.set('v.visibility', wrapper.visibility);
        const val = [
            { label: 'Daily', value: 'Daily' },
            { label: 'Weekly', value: 'Weekly' },
            { label: 'Monthly', value: 'Monthly' },
            { label: 'Yearly', value: 'Yearly' }
        ];

        component.set('v.recurrenceFrequency', val);
    },
    resetTaskValues: function(component, event, helper) {
        component.set('v.dayRemind', 0);
        if (component.get('v.taskConfig.isRecurrence')) {
            component.set('v.showNumbersAdd', true);
        }
    },
    checkRecurrence: function(component, event, helper) {
        console.log('checkRecurrence');
        let startDate = component.get('v.taskConfig.startDate');
        let dueDate = component.get('v.taskConfig.endTime');
        let reccFrequency = component.get('v.taskConfig.recurrenceFrequency');
        console.log('startDate: ' + startDate + ' dueDate: ' + dueDate);
        dueDate = moment(dueDate, 'YYYY-MM-DD');
        console.log('diff: ' + dueDate.diff(startDate, 'days'));
        let diffInDays = dueDate.diff(startDate, 'days');
        if (reccFrequency == 'Weekly' && diffInDays < 7) {
            component.set('v.isValid', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + 'Cannot set weekly task for these dates',
                10000
            );
        } else if (reccFrequency == 'Monthly' && diffInDays < 31) {
            component.set('v.isValid', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + 'Cannot set monthly task for these dates',
                10000
            );
        } else if (reccFrequency == 'Yearly' && diffInDays < 366) {
            component.set('v.isValid', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + 'Cannot set yearly task for these dates',
                10000
            );
        } else {
            var a = component.get('c.doCheckFields');
            $A.enqueueAction(a);
        }
        console.log('isValid: ' + component.get('v.isValid'));
    },
    doCheckFields: function(component, event, helper) {
        let allValid = component.find('field').reduce(function(validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValid', allValid);
        component.get('v.parent').setValidity(allValid);
    },

    onDaysChange: function(component, event, helper) {
        let startDate = component.get('v.taskConfig.startDate');
        let dueDate = component.get('v.taskConfig.endTime');
        let reminderDate = component.get('v.taskConfig.reminderDate');
        let useDaysNumber = component.get('v.showNumbersAdd') === 'true';
        if (component.get('v.dayRemind') != 0) {
            component.set('v.taskConfig.reminderDays', component.get('v.dayRemind'));
        }
        if (component.get('v.dayRemind') > 6) {
            component.set('v.isValid', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + 'Cannot set task reminder more than 6 days',
                10000
            );
            return;
        } else {
            var a = component.get('c.doCheckFields');
            $A.enqueueAction(a);
        }
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

        var a = component.get('c.checkRecurrence');
        if (component.get('v.taskConfig.isRecurrence')) {
            $A.enqueueAction(a);
        }
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

    dueNumberKeyPress: function(component, event, helper) {
        //Fired on press any key in field
        if (event.which === 13) helper.setDays(component);
    }
});
