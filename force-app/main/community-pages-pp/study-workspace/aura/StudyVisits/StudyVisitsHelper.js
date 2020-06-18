/**
 * Created by dmytro.fedchyshyn on 02.09.2019.
 */

({
    createStudyVisitReminder: function (component, visitWrapper) {
        debugger;
        var title = $A.util.isUndefinedOrNull(visitWrapper.task.Id) ? $A.get('$Label.c.PP_Create_Visit_Reminder') : $A.get('$Label.c.PP_Edit_Visit_Reminder');
        var isNewTask = $A.util.isUndefinedOrNull(visitWrapper.task.Id) ? true : false;
        $A.createComponent("c:StudyVisitReminder",
            {
                "aura:id" : "studyVisitReminder",
                "visitId": visitWrapper.visit.Id,
                "taskId": visitWrapper.task.Id,
                "title":  title,
                "taskType": 'Visit',
                "visitData": visitWrapper,
                "isNewTask": isNewTask
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

});