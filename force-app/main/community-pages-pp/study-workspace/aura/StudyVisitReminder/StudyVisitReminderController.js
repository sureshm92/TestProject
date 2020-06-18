({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        var params = event.getParam('arguments');
        if(params){
            console.log('#relaodAttributes: '+ JSON.stringify(params.relaodAttributes));
            component.set('v.visitId', params.relaodAttributes.visitId);
            component.set('v.taskId', params.relaodAttributes.taskId);
            component.set('v.taskType', params.relaodAttributes.taskType);
            component.set('v.visitData', params.relaodAttributes.visitData);
            component.set('v.isNewTask', params.relaodAttributes.isNewTask);
            component.set('v.title', params.relaodAttributes.title);
        }
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
        
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValidFields', allValid);
    },
    
    doNavigateToAccountSettings: function(component, event, helper){
        communityService.navigateToPage('account-settings');
    },
    
    doChangePreference: function(component, event, helper){
        
    }
})