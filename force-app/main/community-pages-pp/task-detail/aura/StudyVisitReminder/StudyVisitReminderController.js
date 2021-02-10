({
    doInit: function (component, event, helper) {
        //component.find('spinner').show();
        var params = event.getParam('arguments');
        if (params) {
            console.log('#relaodAttributes: ' + JSON.stringify(params.relaodAttributes));
            component.set('v.visitId', params.relaodAttributes.visitId);
            component.set('v.taskId', params.relaodAttributes.taskId);
            component.set('v.taskType', params.relaodAttributes.taskType);
            component.set('v.visitData', params.relaodAttributes.visitData);
            component.set('v.taskData', params.relaodAttributes.taskData);
            component.set('v.isNewTask', params.relaodAttributes.isNewTask);
            component.set('v.title', params.relaodAttributes.title);
            component.set('v.isReminderOnly', params.relaodAttributes.isReminderOnly);
        }

        helper.initialize(component, helper);
        //this.reRender = true;
        //Take scroll bar to top next time when the popup is displayed
        //if (!component.get('v.isReminderOnly')) {
        document.getElementsByClassName('with-scroll')[0].scrollTop = 0;
        //}
    },

    doCancel: function (component, event, helper) {
        helper.hideModal(component);
        this.reRender = false;
    },

    doSave: function (component, event, helper) {
        var task = component.get('v.task');
        var visitDate = component.get('v.visitData.visitDate');
        var patientVisit = {'sobjectType' : 'Patient_Visit__c', 'Id':component.get('v.visitData.visit.Id'),'Planned_Date__c' :visitDate ,'Status__c':'Scheduled'};
        if(task.Task_Type__c == 'Visit'){
            communityService.executeAction(
                component,
                'updatePatientVisits',
                {
                    visit: JSON.stringify(patientVisit)
                },
                function (returnValue) {
                    
                },
                null,
                function () {
                    
                }
            );
        }
        task.Task_Type__c =
            $A.util.isEmpty(task.Task_Type__c) && !component.get('v.initData.createdByAdmin')
                ? 'Not Selected'
                : task.Task_Type__c;
        var reminderDate = component.get('v.initData.reminderDate');
        var emailPeferenceSelected = component.get('v.task.Remind_Using_Email__c');
        var smsPeferenceSelected = component.get('v.task.Remind_Using_SMS__c');
        var emailOptIn = component.get('v.emailOptIn');
        var smsOptIn = component.get('v.smsOptIn');
        if (!task.Subject) {
            communityService.showErrorToast('', $A.get('$Label.c.Empty_TaskName'), 3000);
            return;
        }
        if (
            !$A.util.isUndefinedOrNull(reminderDate) &&
            !(smsPeferenceSelected && smsOptIn) &&
            !(emailPeferenceSelected && emailOptIn)
        ) {
            communityService.showErrorToast('', $A.get('$Label.c.PP_Remind_Using_Required'), 3000);
            return;
        }
        var isValidFields =
            helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component);
        if (!component.get('v.isValidFields') || !isValidFields) {
            var showToast = true;
            if (!component.get('v.isNewTask')) {
                if (
                    component.get('v.jsonState') ===
                    JSON.stringify(component.get('v.initData')) + '' + JSON.stringify(task)
                ) {
                    showToast = false;
                }
            }
            if (showToast) {
                communityService.showErrorToast('', $A.get('$Label.c.Incorrect_data'), 3000);
                return;
            }
        }
        var message = helper.setSuccessToast(component);
        component.find('spinner').show();
        if(task.Task_Type__c == 'Visit'){
            component.set('v.initData.activityDate',visitDate);
        }
        communityService.executeAction(
            component,
            'upsertTask',
            {
                wrapper: JSON.stringify(component.get('v.initData')),
                paramTask: JSON.stringify(task)
            },
            function () {
                component.set('v.isSaveOperation', true);
                component.find('spinner').hide();
                communityService.showSuccessToast('', message, 3000);
                helper.hideModal(component);
            },
            function () {
                component.find('spinner').hide();
            },
            null
        );
    },

    doIgnore: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'ignoreTask');
    },

    doMarkComplete: function (component, event, helper) {
        helper.updateTaskStatus(component, helper, 'markAsCompleted');
    },

    setOneDayBefore: function (component, event, helper) {
        var reminderDate = moment(component.get('v.initData.reminderDate'), 'YYYY-MM-DD');
        reminderDate.subtract(1, 'days');
        component.set('v.initData.reminderDate', reminderDate.format('YYYY-MM-DD'));
    },

    doValidateFields: function (component, event, helper) {
        console.log('isTaskTab-->'+component.get('v.isTaskTab'));
        var remindMe = component.get('v.task.Remind_Me__c');
        var isTaskTab = component.get('v.isTaskTab') == true;
        var isReminderOnly = component.get('v.isReminderOnly');
        var reminderOptionValid = !isTaskTab?component.find('reminderOption'): !isReminderOnly?component.find('taskReminderOption'):component.find('taskReminderOption1');
        var isGreaterThanToday = false;
        var dueDateOrplanDate = !isTaskTab?component.get('v.visitData.visitDate'):component.get('v.initData.activityDate');
        var today = moment();
         if(remindMe !== 'Custom'){
         if(remindMe === '1 Week before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today)
         }else if(remindMe === '1 day before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today)
         }else if(remindMe === '1 hour before'){
             var reminderdate = new Date(dueDateOrplanDate) - (3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }else if(remindMe === '4 hours before'){
             var reminderdate = new Date(dueDateOrplanDate) - (4*3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }
         if(isGreaterThanToday){
             if(!$A.util.isUndefinedOrNull(reminderOptionValid)){
               reminderOptionValid.setCustomValidity($A.get('$Label.c.PP_Reminder_Error_Message'));
               reminderOptionValid.reportValidity();  
             }
         }else{
             if(!$A.util.isUndefinedOrNull(reminderOptionValid)){
                reminderOptionValid.setCustomValidity(' ');
             reminderOptionValid.reportValidity(); 
             }
         }
         }else{
              if(!$A.util.isUndefinedOrNull(reminderOptionValid)){
                reminderOptionValid.setCustomValidity(' ');
             reminderOptionValid.reportValidity(); 
             }
         }
       
        var isValidFields = helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component) ;
        //component.set('v.isValidFields', isValidFields);
        console.log('reminderDate-->'+ $A.util.isUndefinedOrNull(component.get('v.initData.reminderDate')));
        console.log('isValidFields-->'+(!isValidFields));
        console.log('dueDateOrplanDate-->'+$A.util.isUndefinedOrNull(dueDateOrplanDate));
        console.log('isGreaterThanToday-->'+isGreaterThanToday);
        console.log('inside condition-->'+($A.util.isUndefinedOrNull(dueDateOrplanDate) || isGreaterThanToday || $A.util.isUndefinedOrNull(component.get('v.initData.reminderDate') || !isValidFields)));
        
        if($A.util.isUndefinedOrNull(dueDateOrplanDate) || isGreaterThanToday || !isValidFields || ($A.util.isUndefinedOrNull(component.get('v.initData.reminderDate')) && remindMe === 'Custom')){
                   component.set('v.isValidFields', false);
           }
           else{
                  component.set('v.isValidFields', true);
           }
    },

    doNavigateToAccountSettings: function (component, event, helper) {
        window.open('account-settings', '_blank');
        window.focus();
        helper.hideModal(component);
    },

    setAttributeValue: function (component, event, helper) {
        var sourceEvt = event.getSource();
        switch (sourceEvt.get('v.name')) {
            case 'Email':
                component.set('v.task.Remind_Using_Email__c', sourceEvt.get('v.checked'));
                break;
            case 'SMS':
                component.set('v.task.Remind_Using_SMS__c', sourceEvt.get('v.checked'));
                break;
        }
    }
    ,
    doValidateReminderFrequency: function (component,helper) {
       /* var remindMe = component.get('v.task.Remind_Me__c');
        var task = component.get('v.task');
        var reminderOptionValid = task.Task_Type__c == 'Visit'? component.find('reminderOption'):component.find('taskReminderOption');
        var isGreaterThanToday = false;
        var dueDateOrplanDate = task.Task_Type__c == 'Visit'?component.get('v.visitData.visitDate'):component.get('v.initData.activityDate');
        var today = moment();
         if(remindMe !== 'Custom'){
         if(remindMe === '1 Week before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today)
         }else if(remindMe === '1 day before'){
             isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today)
         }else if(remindMe === '1 hour before'){
             var reminderdate = new Date(dueDateOrplanDate) - (3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }else if(remindMe === '4 hours before'){
             var reminderdate = new Date(dueDateOrplanDate) - (4*3600*1000);
             isGreaterThanToday = new Date() > new Date(reminderdate);
         }
         if(isGreaterThanToday){
               reminderOptionValid.setCustomValidity('Reminder Date cannot be in the past');
               reminderOptionValid.reportValidity();
         }else{
             reminderOptionValid.setCustomValidity(' ');
             reminderOptionValid.reportValidity();
         }
         }
        
      // var isValidFields = helper.doValidateDueDate(component, helper) && helper.doValidateReminder(component) ;
       //component.set('v.isValidFields', isValidFields);
       if($A.util.isUndefinedOrNull(dueDateOrplanDate) || isGreaterThanToday || component.get('v.isValidFields') == false){
                   component.set('v.isValidFields', false);
        }
       else{
                  component.set('v.isValidFields', true);
           }*/

    }

      
});