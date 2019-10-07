/**
 * Created by Igor Malyuta on 30.05.2019.
 */

({
    doInit: function (component, event, helper) {
        var spinner = component.find('spinner');
        spinner.show();
        helper.getData(component, function () {
            spinner.hide();
            component.set('v.inProcess', false);
        });
        setInterval($A.getCallback(function () {
            if(!component.get('v.inProcess')){
                helper.getData(component);
            }
        }), 1500);
    },

    clickRun: function (component, event, helper) {
        var jobName = event.currentTarget.dataset.record;
        component.find('spinner').show();
        component.set('v.inProcess', true);
        communityService.executeAction(component, 'runBatch', {
                jobName: jobName
            }, function () {
                helper.waitStateChange(component, jobName, 'RUNNING,SCHEDULED', function () {
                    communityService.showSuccessToast('', 'Batch launched successfully!');
                });
            }
        );
    },

    clickStop: function (component, event, helper) {
        var jobName = event.currentTarget.dataset.record;
        component.find('spinner').show();
        component.set('v.inProcess', true);
        communityService.executeAction(component, 'stopBatch',
            {
                jobName: jobName
            }, function () {
                helper.waitStateChange(component, jobName, 'STOPPED', function () {
                    communityService.showInfoToast('', 'Batch stopped successfully!');
                });
            });
    },

    clickRunMode: function (component, event, helper) {
        communityService.executeAction(component, 'runFAQ',
            {
                mode: event.currentTarget.dataset.record
            }, function () {
                communityService.showSuccessToast('', 'Batch launched successfully!');
                component.refresh();
            });
    }
});