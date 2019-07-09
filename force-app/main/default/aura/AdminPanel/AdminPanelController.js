/**
 * Created by Igor Malyuta on 30.05.2019.
 */

({
    doInit: function (component, event, helper) {
        helper.getData(component, true);
        setInterval($A.getCallback(function () {
            helper.getData(component, false)
        }), 2500);
    },

    clickRun: function (component, event, helper) {
        var jobList = component.get('v.jobs');
        var jobName = event.currentTarget.dataset.record;

        for (var i = 0; i < jobList.length; i++) {
            if (jobList[i].jobName === jobName) {
                jobList[i].showSpinner = true;
                break;
            }
        }
        component.set('v.jobs', jobList);

        communityService.executeAction(component, 'runBatch',
            {
                'jobName': jobName
            }, function () {
                helper.waitStateChange(component, jobName);
            }
        );
    },

    clickStop: function (component, event, helper) {
        communityService.executeAction(component, 'stopBatch',
            {
                'jobName': event.currentTarget.dataset.record
            }, function () {
                communityService.showSuccessToast('', 'Batch stopped successfully!');
                component.refresh();
            });
    },

    clickRunMode: function (component, event, helper) {
        communityService.executeAction(component, 'runFAQ',
            {
                'mode': event.currentTarget.dataset.record
            }, function () {
                communityService.showSuccessToast('', 'Batch launched successfully!');
                component.refresh();
            });
    }
});