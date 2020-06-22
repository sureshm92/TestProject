({
    initialize: function (component) {
        debugger;
        var taskId = component.get('v.taskId');
        var isNewTask = component.get('v.isNewTask');
        var visitId = component.get('v.visitId');
        var visitData = component.get('v.visitData');
        var taskType = component.get('v.taskType');
        if (!communityService.isDummy()) {
            communityService.executeAction(component, 'getTaskEditData', {
                taskId: taskId
            }, function (wrapper) {
                console.log('##wrapper: ' + JSON.stringify(wrapper));
                component.set('v.initData', wrapper);
                component.set('v.isEnrolled', wrapper.isEnrolled);
                component.set('v.emailOptIn', wrapper.emailOptIn);
                component.set('v.smsOptIn', wrapper.smsOptIn);
                
                if (!wrapper.emailOptIn || !wrapper.smsOptIn) {
                    component.set('v.showAccountNavigation', true);
                }
                component.set('v.taskTypeList', wrapper.taskTypeList);
                var task = wrapper.task;
                if (isNewTask) {
                    if(taskType === 'Visit'){
                        task.Subject = visitData.visit.Is_Adhoc__c
                        ? $A.get('$Label.c.StudyVisit_Unscheduled_Visit')
                        : visitData.visit.Visit__r.Patient_Portal_Name__c;
                        wrapper.activityDate = visitData.completedOrPlannedDate == $A.get('$Label.c.Study_Visit_Unavailable') ? null : visitData.completedOrPlannedDate; //moment(visitData.completedOrPlannedDate, 'YYYY-MM-DD'); 
                        component.set('v.isEditable', false);
                    }
                    task.Status = 'Open';
                    task.Task_Type__c = taskType;
                } else {
                    if (wrapper.activityDate && wrapper.reminderDate) {
                        var due = moment(wrapper.activityDate, 'YYYY-MM-DD');
                        var reminder = moment(wrapper.reminderDate, 'YYYY-MM-DD');
                        if (!due.isSame(reminder)) {
                            if (due.diff(reminder, 'days') === 1) {
                                component.set('v.frequencyMode', 'Day_Before');
                                component.set('v.reminderDateEnabled', false);
                            }
                        }
                    }
                    var isOwner = task.OwnerId === task.CreatedById;
                    component.set('v.owner', isOwner);
                    component.set('v.editAvailable', isOwner && task.Status !== 'Completed' && taskType !== 'Visit');
                }
                component.set('v.task', task);
                
                if (!$A.util.isUndefinedOrNull(visitId)) {
                    component.set('v.task.Patient_Visit__c', visitId);
                }
                
                component.set('v.jsonState', JSON.stringify(wrapper) + '' + JSON.stringify(task));
                component.set('v.isValidFields', true);
                //component.find('spinner').hide();
                component.find('reminderModal').show();
            });
        } else {
            //component.find('spinner').hide();
            component.find('builderStub').setPageName(component.getName());
        }
        
    },
    
    updateTaskStatus: function (component, helper, method) {
        component.find('spinner').show();
        communityService.executeAction(component, method, {
            'taskId': component.get('v.taskId')
        }, function () {
            component.find('spinner').hide();
            component.set('v.isSaveOperation', true);
        }, null, function () {
            helper.hideModal(component);
        });
    },
    
    //Just for safe-keeping. Might use it when Planned_Date_c
    //for Patient Visit is populated by SDH
    isSameDay: function (component) {
        var today = component.get('v.initData.today');
        var dueDate = component.get('v.initData.activityDate');
        dueDate = moment(dueDate, 'YYYY-MM-DD');
        
        return dueDate.isSame(today);
    },
    
    hideModal: function (component) {
        debugger;
        var isSaveOperation = component.get('v.isSaveOperation');
        component.find('reminderModal').hide();
        if(isSaveOperation){
            component.set('v.isSaveOperation', false);
            component.get('v.parent').reload();
        }
    },
    
    setSuccessToast: function (component){
        
        var isReminderOnly = component.get('v.isReminderOnly');
        var isNewTask = component.get('v.isNewTask');
        //Task created successfully. ; Changes are successfully saved. ; Visit reminder created successfully. ; Visit reminder updated.
        var successToastArray = $A.get('$Label.c.PP_Task_Success_Toast').split(';');
        var message = '';
        if (isNewTask && !isReminderOnly){
            message = successToastArray[0].trim();
        } else if (isNewTask && isReminderOnly){
            message = successToastArray[2].trim();
        } else if (!isNewTask && !isReminderOnly){
            message = successToastArray[1].trim();
        } else{
            message = successToastArray[3].trim();
        }
        
        return message;
    }
})