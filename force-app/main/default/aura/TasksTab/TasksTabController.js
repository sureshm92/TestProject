/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getParticipantTasks', null, function (participantTasks) {
            helper.updateTasks(component, participantTasks);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doCreateNewTask: function (component, event, helper) {
        communityService.navigateToPage('edit-task');
    },

    doIgnoreTask: function (component, event, helper) {
        var taskId = event.currentTarget.id;
        component.find('spinner').show();
        communityService.executeAction(component, 'ignoreTask', {
            taskId: taskId
        }, function (participantTasks) {
            helper.updateTasks(component, participantTasks);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCompleteTask: function (component, event, helper) {
        var taskId = event.currentTarget.id;
        component.find('spinner').show();
        communityService.executeAction(component, 'completeTask', {
            taskId: taskId
        }, function (participantTasks) {
            helper.updateTasks(component, participantTasks);
        }, null, function () {
            component.find('spinner').hide();
        });
    }

})