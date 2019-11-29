/**
 * Created by Igor Malyuta on 04.06.2019.
 */

({
    waitStateChange: function (component, jobName, waitedState, callback) {
        var helper = this;
        communityService.executeAction(component, 'getState', {
            'jobName': jobName
        }, function (wrapper) {
            if (waitedState.indexOf(wrapper.state) !== -1) {
                var jobList = component.get('v.jobs');
                for (var i = 0; i < jobList.length; i++) {
                    if (jobList[i].jobName === jobName) {
                        jobList[i] = wrapper;
                        break;
                    }
                }
                component.set('v.jobs', jobList);
                component.find('spinner').hide();
                component.set('v.inProcess', false);
                callback();
            } else {
                setTimeout(
                    $A.getCallback(function () {
                        helper.waitStateChange(component, jobName, waitedState, callback);
                    }), 500
                );
            }
        });
    },

    getData : function (component, callback) {
        communityService.executeAction(component, 'getData', null, function (response) {
            if(!component.get('v.inProcess'))component.set('v.jobs', response);
            if(callback) callback();
        });
    }
});