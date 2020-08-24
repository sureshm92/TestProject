({
    createStudyVisitReminder: function (component, title, taskData, isReminderOnly) {
        component.find('spinner').show();
        var task;
        if(taskData.openTask){            
            task = taskData.openTask;
        } else if(taskData){           
            task = taskData; 
        }else{
            task = null;
            var isNewTask = true;
        }
        $A.createComponent("c:StudyVisitReminder",
            {
                "aura:id" : "studyVisitReminder",
                "visitId": !$A.util.isUndefinedOrNull(task) ? task.Patient_Visit__c : null,
                "taskId": !$A.util.isUndefinedOrNull(task) ? task.Id : null,
                "title":  title,
                "taskType": !$A.util.isUndefinedOrNull(task) ? task.Task_Type__c : '',
                "taskData": taskData,
                "isNewTask": isNewTask,
                "isTaskTab": true,
                "isReminderOnly": isReminderOnly,
                "parent": component.get('v.cmpDef')
            },
            function (reminder, status, errorMessage) {
                if (component.isValid() && status === "SUCCESS") {                    
                    let visitReminder = component.find('visitReminder');
                    let body = visitReminder.get('v.body');
                    body.push(reminder);
                    visitReminder.set('v.body', body);
                    component.set('v.firstLoad', true);
                    component.find('spinner').hide();
                } else if (status === "INCOMPLETE") {                   
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {                   
                    console.log("Error: " + errorMessage);
                }
            });

    },
    
    setReloadAttributes: function(component, taskData, title, isOpenTask, isReminderOnly){        
        var task = taskData;
         
        let relaodAttributes = {
                "visitId": task.Patient_Visit__c,
                "taskId": task.Id,
                "title":  title,
                "taskType": taskData.Task_Type__c,
                "taskData": taskData,
                "isNewTask": false,
                "isReminderOnly": isReminderOnly,
                "isTaskTab": true
            };
        return relaodAttributes;
    }
})