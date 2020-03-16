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
        communityService.executeAction(component, 'taskClicked', {
            id: event.getParam('identifier'),
            message: event.getParam('message')
        });
    }
});