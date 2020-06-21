/**
 * Created by Leonid Bartenev--
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getParticipantTasks', null, function (participantTasks) {
            component.set('v.openTasks', participantTasks.openTasksWrapper);
            component.set('v.completedTasks', participantTasks.completedTasks);
            component.set('v.emptyTaskLabel', participantTasks.emptyText);
            component.set('v.initialized', true);
            component.set('v.showCreateTaskButton', participantTasks.showCreateTaskButton);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doCreateNewTask: function (component, event, helper) {
        //communityService.navigateToPage('task-detail');
        let firstLoad = component.get('v.firstLoad');
        let title = $A.get('$Label.c.TTL_Create_Task');
        let taskData = {};
        if(!firstLoad){
            helper.createStudyVisitReminder(component, title, taskData);
        } else{
            //TO-DO: Add necessary arguments later
            taskData.title = $A.get('$Label.c.TTL_Create_Task');
            component.find('studyVisitReminder').reloadPopup(taskData);
        }
    },

    doTaskClick: function (component, event, helper) {
        debugger;
        console.log(JSON.stringify(event.currentTarget.dataset));
        let index = event.currentTarget.dataset.index;
        let taskData = component.get('v.openTasks')[index];
        console.log('doTaskClick taskData: '+JSON.stringify(taskData));
        let taskId = taskData.openTask.Id;
        let actionURL = taskData.openTask.Action_URL__c;
        let firstLoad = component.get('v.firstLoad');
        let title = $A.get('$Label.c.TTL_Edit_Task');
        if(!$A.util.isUndefinedOrNull(actionURL)){
            communityService.executeAction(component, 'taskClicked', {
                id: taskId,
                message: actionURL
            }, function(){
                communityService.navigateToPage(actionURL);
            }, null, null);
        } else if(!firstLoad){
            helper.createStudyVisitReminder(component, title, taskData);
        } else{
            let isNewTask = false;
            let relaodAttributes = {
                "visitId": taskData.openTask.Patient_Visit__c,
                "taskId": taskData.openTask.Id,
                "title":  title,
                "taskType": taskData.openTask.Task_Type__c,
                "taskData": taskData,
                "isNewTask": isNewTask
            };
            component.find('studyVisitReminder').reloadPopup(relaodAttributes);
        }
    }
});