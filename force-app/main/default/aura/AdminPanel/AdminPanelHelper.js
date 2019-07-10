/**
 * Created by Igor Malyuta on 04.06.2019.
 */

({
    waitStateChange: function (component, jobName) {
        var jobList = component.get('v.jobs');
        var helper = this;

        communityService.executeAction(component, 'getState', {
            'jobName': jobName
        }, function (wrapper) {
            if (wrapper.state === 'STOPPED') {
                setTimeout(
                    $A.getCallback(function () {
                        helper.waitStateChange(component, jobName);
                    }), 500
                );
            } else {
                for (var i = 0; i < jobList.length; i++) {
                    if (jobList[i].jobName === jobName) {
                        jobList[i] = wrapper;
                        break;
                    }
                }
                component.set('v.jobs', jobList);
                communityService.showSuccessToast('', 'Batch launched successfully!');
            }
        });
    },

    getData : function (component, callback) {
        communityService.executeAction(component, 'getData', null, function (response) {
            component.set('v.jobs', response);
        });
        if(callback) callback();
    }
});