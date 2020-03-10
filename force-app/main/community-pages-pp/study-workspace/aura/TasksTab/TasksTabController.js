/**
 * Created by Leonid Bartenev
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
        communityService.navigateToPage('task-detail');
    },

    doTaskClick: function (component, event, helper) {
        let message = event.getParam('message');
        let identifier = event.getParam('identifier');

        if (/\bautocomplete=true\b/i.test(message)) {
            communityService.executeAction(component, 'markAsCompleted', {
                taskId: identifier
            });
        }
    }
});