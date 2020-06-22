/**
 * Created by Pijush Kar
 * 12-June-2020
 */
({
    createStudyVisitReminder: function (component, isNewTask, taskId, taskType, title) {

        $A.createComponent("c:StudyVisitReminder",
            {
                "aura:id" : "studyVisitReminder",
                "isNewTask" : isNewTask,
                "taskId" : taskId,
                "taskType" : taskType,
                "title" : title
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