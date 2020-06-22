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
            component.set('v.taskData', params.relaodAttributes.taskData);
            component.set('v.isNewTask', params.relaodAttributes.isNewTask);
            component.set('v.title', params.relaodAttributes.title);
        }
        helper.initialize(component);
    },

    doCancel: function (component, event, helper) {
        helper.hideModal(component);
    },

    doSave: function (component, event, helper) {
        debugger;
		var task = component.get('v.task');
        var reminderDate = component.get('v.initData.reminderDate');
        
        var emailPeferenceSelected = component.find('emailField').get('v.checked');
        var smsPeferenceSelected = component.find('smsField').get('v.checked');
        
        if (!task.Subject) {
            communityService.showErrorToast('', $A.get('$Label.c.Empty_TaskName'));
            return;
        }
        if(!$A.util.isUndefinedOrNull(reminderDate)
           && !smsPeferenceSelected && !emailPeferenceSelected){
            communityService.showErrorToast('', $A.get('$Label.c.Empty_Reminder'), 3000);
            return;
        }
        if (!component.get('v.isValidFields')) {
            var showToast = true;
            if (!component.get('v.isNewTask')) {
                if (component.get('v.jsonState') ===
                    (JSON.stringify(component.get('v.initData'))) + '' + JSON.stringify(task)) {
                    showToast = false;
                }
            }
            if (showToast) {
                communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'), 3000);
                return;
            }
        }
        component.set('v.task.Remind_Using_Email__c', emailPeferenceSelected);
        component.set('v.task.Remind_Using_SMS__c', smsPeferenceSelected);
        var message = helper.setSuccessToast(component);
        
        component.find('spinner').show();
        
        communityService.executeAction(component, 'upsertTask', {
            'wrapper': JSON.stringify(component.get('v.initData')),
            'paramTask': JSON.stringify(task)
        }, function(){
       		component.find('spinner').hide();
            component.set('v.isSaveOperation', true);
            communityService.showSuccessToast('', message, 3000);
            helper.hideModal(component);
        }, null, null);
    },

    doIgnore: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'ignoreTask');
    },

    doMarkComplete: function (component, event, helper) {
        helper.updateTaskStatus(component, 'markAsCompleted');
    },

    doChangeReminderDate: function (component, event, helper) {
        if (freq === 'Day_Before') {
            $A.enqueueAction(component.get('c.setOneDayBefore'));
        }
    },

    setOneDayBefore: function (component, event, helper) {
        var reminderDate = moment(component.get('v.initData.reminderDate'), 'YYYY-MM-DD');
        reminderDate.subtract(1, 'days');
        component.set('v.initData.reminderDate', reminderDate.format('YYYY-MM-DD'));
	},

    validateFields: function (component, event, helper) {
        if (component.get('v.initData') && component.get('v.initData.createdByAdmin')) return;
        /*console.log(component.find('field'));
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        component.set('v.isValidFields', allValid);*/
    },
    
    doNavigateToAccountSettings: function(component, event, helper){
        communityService.navigateToPage('account-settings');
    },
    
    doChangePreference: function(component, event, helper){
        
    },
    
    onChangeFreq: function (component, event, helper) {
        var freq = component.get('v.frequencyMode');
        if (freq === 'By_Date') {
            component.set('v.initData.reminderDate', component.get('v.initData.activityDate'));
            //component.set('v.reminderDateEnabled', true);
        } else if (freq === 'Day_Before') {
            $A.enqueueAction(component.get('c.setOneDayBefore'));
            //component.set('v.reminderDateEnabled', false);
        }
    }
})
