/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    getRelatedVisitPlans: function (component, event, helper) {
        debugger;
        helper.enqueue(component, 'c.getRelatedPlannedVisits', {
            visitPlanId: component.get('v.recordId')
        }).then(function (result) {
           component.set('v.visits',result)
        }, function(err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
        })
    },
    shiftRight: function (component, event, helper) {
        component.find('editForm').submit();
    },
    shiftLeft: function (component, event, helper) {
        component.find('editForm').submit();
    },


})