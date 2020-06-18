({
    doInit: function (component, event, helper) {
        helper.initialize(component);
    },

    doCancel: function (component, event, helper) {
        helper.hideModal(component);
    },

    doSave: function (component, event, helper) {


    },

    doIgnore: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'ignoreTask');
    },

    doMarkComplete: function (component, event, helper) {
        helper.updateTaskStatus(component, 'markAsCompleted');
    },

    doChangeReminderDate: function (component, event, helper) {
        if (freq === 'Day_Before') {
            $A.enqueueAction(component.get('c.setDueDate'));
        }
    },

    setDueDate: function (component, event, helper) {
        var reminderDate = moment(component.get('v.initData.reminderDate'), 'YYYY-MM-DD');
        reminderDate.add(1, 'days');
        component.set('v.initData.activityDate', reminderDate.format('YYYY-MM-DD'));

    },

    validateFields: function (component, event, helper) {
        if (component.get('v.initData') && component.get('v.initData.createdByAdmin')) return;

        var allValid = component.find('dateField').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValidFields', allValid);
    }
})
