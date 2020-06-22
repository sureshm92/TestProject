/**
 * Created by Pijush Kar
 * 12-June-2020
 */
({
    createStudyVisitReminder: function (component, title, taskData) {
        console.log('TasksTabHelper: '+JSON.stringify(taskData));
        var task;
        if(taskData.openTask){
            task = taskData.openTask;
        } else if(taskData.task){
            task = taskData.task; 
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
                "parent": component.get('v.cmpDef')
            },
            function (reminder, status, errorMessage) {
                if (component.isValid() && status === "SUCCESS") {
                    let visitReminder = component.find('visitReminder');
                    let body = visitReminder.get('v.body');
                    body.push(reminder);
                    visitReminder.set('v.body', body);
                    component.set('v.firstLoad', true);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });

    }
})