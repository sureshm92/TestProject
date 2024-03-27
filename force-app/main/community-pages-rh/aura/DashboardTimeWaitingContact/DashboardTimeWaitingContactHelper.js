({
    loadData: function (component, event, helper) {
        component.set('v.loaded', true);
        var action = component.get('c.prepareWaitingList');
        action.setParams({
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId(),
            piId: component.get('v.currentPi'),
            ctpId: component.get('v.currentStudy')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                component.set('v.peList', returnValue);
                var count =
                    parseInt(returnValue[0].count) +
                    parseInt(returnValue[1].count) +
                    parseInt(returnValue[2].count) +
                    parseInt(returnValue[3].count) +
                    parseInt(returnValue[4].count);
                    component.set('v.totalcount', count);


                component.set('v.loaded', false);
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