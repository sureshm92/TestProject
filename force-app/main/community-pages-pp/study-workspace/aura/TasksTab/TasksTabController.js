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
        let title = $A.get('$Label.c.BTN_Create_New_Task');
        if(!firstLoad){
            helper.createStudyVisitReminder(component, true, null, null, title);
        } else{
            //TO-DO: Add necessary arguments later
            component.find('studyVisitReminder').reloadPopup();
        }
    },

    doTaskClick: function (component, event, helper) {
        /*debugger;
        communityService.executeAction(component, 'taskClicked', {
            id: event.getParam('identifier'),
            message: event.getParam('message')
        });*/
    }
});