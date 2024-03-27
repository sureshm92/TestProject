({
    loadData: function (component, event, helper) {
        component.set('v.loaded', true);
        var currentStudy = component.get('v.currentStudy');
        var currentPI = component.get('v.currentPi');
        var action = component.get('c.getStudySiteDetails');
        action.setParams({ pIid: currentPI, studyid: currentStudy });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                var piStudySites = [];
                for (var i in data) {
                    if (data[i].pi_Id == currentPI) {
                        piStudySites.push(data[i]);
                    }
                }
                component.set('v.siteRankWrapper', piStudySites);
                component.set('v.totalcountpisites',piStudySites.length);
                if(piStudySites.length===0){
                    var dummyValue = [{
                        "contacted":0,
                        "enrolled_randomized":0,
                        "initial_Visits_Completed":0,
                        "rank":0,"scheduled":0,
                        "screened":0,
                        "site_Name":'N/A'}];
                        component.set('v.siteRankWrapper',dummyValue);
                }
                component.set('v.loaded', false);
            } else {
                helper.showError(component, event, helper, action.getError()[0].message);
                component.set('v.loaded', false);
            }
        });
        $A.enqueueAction(action);
    },

    getSitesCount: function (component, event, helper) {
        var action = component.get('c.getCurrentStudySitesCount');
        action.setParams({ ctpId: component.get('v.currentStudy') });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = JSON.parse(response.getReturnValue());
                component.set('v.totalSSCount', data);
            } else {
                helper.showError(component, event, helper, action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    showError: function (component, event, helper, errorMsg) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            message: errorMsg,
            duration: '400',
            type: 'error'
        });
        toastEvent.fire();
    }
});
