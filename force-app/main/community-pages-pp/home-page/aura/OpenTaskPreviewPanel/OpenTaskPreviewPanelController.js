/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getPreviewTasks', null, function (tasks) {
            component.set('v.tasks', tasks);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
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