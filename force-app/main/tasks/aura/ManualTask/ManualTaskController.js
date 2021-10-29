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
    doneRendering: function(component, event, helper) {
        if (!component.get('v.isDoneRendering')) {
            if (component.get('v.isEdit')) {
                var elements = component.find('a_opt');
                component.set('v.showNumbersAdd', component.get('v.taskConfig').showNumbersAdd);
                if (elements) {
                    if (component.get('v.taskConfig').showNumbersAdd == true) {
                        component.set('v.isDoneRendering', true);
                        component.find('a_opt').set('v.value', 'true');
                    } else if (component.get('v.taskConfig').showNumbersAdd == false) {
                        component.set('v.isDoneRendering', true);
                        component.find('a_opt').set('v.value', 'false');
                    }
                }
            }
        }
    },
    resetTaskValues: function(component, event, helper) {
        component.set('v.dayRemind', 0);
        component.set('v.taskConfig.reminderDate', null);
        component.set('v.showNumbersAdd', 'true');
        if (component.get('v.dayRemind') != 0) {
            component.set('v.taskConfig.reminderDays', component.get('v.dayRemind'));
        } else if (
            component.get('v.dayRemind') == 0 &&
            component.get('v.taskConfig.isRecurrence')
        ) {
            component.set('v.taskConfig.reminderDays', null);
        } else if (
            component.get('v.dayRemind') == 0 &&
            !component.get('v.taskConfig.isRecurrence') &&
            component.get('v.showNumbersAdd') == 'true'
        ) {
            component.set('v.taskConfig.reminderDays', null);
        }
        component.set('v.taskConfig.showNumbersAdd', component.get('v.showNumbersAdd'));
    },
    checkRecurrence: function(component, event, helper) {
        let startDate = component.get('v.taskConfig.startDate');
        let dueDate = component.get('v.taskConfig.endTime');
        let reccFrequency = component.get('v.taskConfig.recurrenceFrequency');
        dueDate = moment(dueDate, 'YYYY-MM-DD');
        let yearsDiff = dueDate.diff(startDate, 'years');
        let monthDiff = dueDate.diff(startDate, 'months');
        let diffInDays = dueDate.diff(startDate, 'days');
        if (reccFrequency == 'Weekly' && diffInDays < 7) {
            component.set('v.isValid', false);
            component.set('v.freqValidation', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + $A.get('$Label.c.weekly_task_error'),
                10000
            );
        } else if (reccFrequency == 'Monthly' && monthDiff < 1) {
            component.set('v.isValid', false);
            component.set('v.freqValidation', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + $A.get('$Label.c.monthly_task_error'),
                10000
            );
        } else if (reccFrequency == 'Yearly' && yearsDiff < 1) {
            component.set('v.isValid', false);
            component.set('v.freqValidation', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + $A.get('$Label.c.yearly_task_error'),
                10000
            );
        } else {
            component.set('v.freqValidation', true);
            var a = component.get('c.doCheckFields');
            $A.enqueueAction(a);
        }
    },
    doCheckFields: function(component, event, helper) {
        if (component.get('v.isEdit')) {
            let allValid;
            if (
                component.find('fieldEdit1').get('v.validity').valid &&
                component.find('fieldEdit2').get('v.validity').valid &&
                component.find('fieldEdit3').get('v.validity').valid &&
                component.get('v.freqValidation')
            ) {
                allValid = true;
            } else {
                allValid = false;
            }
            component.set('v.isValidSave', allValid);
            component.get('v.parent').setSaveValidity(allValid);
        } else {
            let allValid = component.find('field').reduce(function(validSoFar, inputCmp) {
                return validSoFar && inputCmp.checkValidity();
            }, true);

            component.set('v.isValid', allValid);
            component.get('v.parent').setValidity(allValid);
        }
    },
    setReminderChange: function(component, event, helper) {
        component.set('v.taskConfig.showNumbersAdd', component.get('v.showNumbersAdd'));
        if (
            component.get('v.dayRemind') != 0 &&
            !component.get('v.taskConfig.isRecurrence') &&
            component.get('v.showNumbersAdd') == 'true'
        ) {
            component.set('v.taskConfig.reminderDays', component.get('v.dayRemind'));
        }
    },
    onDaysChange: function(component, event, helper) {
        let startDate = component.get('v.taskConfig.startDate');
        let dueDate = component.get('v.taskConfig.endTime');
        let reminderDate = component.get('v.taskConfig.reminderDate');
        let useDaysNumber = component.get('v.showNumbersAdd') === 'true';
        if (component.get('v.dayRemind') != 0) {
            component.set('v.taskConfig.reminderDays', component.get('v.dayRemind'));
        } else if (
            component.get('v.dayRemind') == 0 &&
            component.get('v.taskConfig.isRecurrence')
        ) {
            component.set('v.taskConfig.reminderDays', null);
            component.set('v.taskConfig.reminderDate', null);
        }
        if (component.get('v.dayRemind') > 365 && component.get('v.taskConfig.isRecurrence')) {
            component.set('v.isValid', false);
            component.get('v.parent').setValidity(false);
            communityService.showToast(
                'Error',
                'error',
                '\n' + $A.get('$Label.c.reminder_greaterthan_one_year_error'),
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
                component.set('v.taskConfig.reminderDays', daysBetween);
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
        if (
            //condition for resetting rem days to 0
            component.get('v.taskConfig.reminderDate') == null &&
            component.get('v.showNumbersAdd') != 'true'
        ) {
            console.log('inside new condition');
            component.set('v.taskConfig.reminderDays', null);
            component.set('v.dayRemind', null);
        }
        if (
            //condition for resetting rem date to null
            component.get('v.dayRemind') == 0 &&
            component.get('v.showNumbersAdd') == 'true'
        ) {
            console.log('inside new condition 2');
            component.set('v.taskConfig.reminderDate', null);
            component.set('v.taskConfig.reminderDays', null);
            component.set('v.dayRemind', null);
        }
        component.set('v.taskConfig.showNumbersAdd', component.get('v.showNumbersAdd'));
    },

    dueNumberKeyPress: function(component, event, helper) {
        //Fired on press any key in field
        if (event.which === 13) helper.setDays(component);
    }
});
