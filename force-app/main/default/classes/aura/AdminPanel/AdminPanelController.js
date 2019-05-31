/**
 * Created by Igor Malyuta on 30.05.2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getData', null, function (response) {
            component.set('v.jobs', JSON.parse(response));
        });
    },

    clickRun: function (component, event, helper) {
        communityService.executeAction(component, 'runBatch',
            {
                'jobName' : event.currentTarget.dataset.record
            }, function () {
                communityService.showSuccessToast('', 'Batch launched successfully!');
                helper.reload(component);
            }
        );
    },

    clickStop: function (component, event, helper) {
        communityService.executeAction(component, 'stopBatch',
            {
                'jobName' : event.currentTarget.dataset.record
            }, function () {
                communityService.showSuccessToast('', 'Batch stopped successfully!');
                helper.reload(component);
            });
    }
});