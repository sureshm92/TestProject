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
    }
})