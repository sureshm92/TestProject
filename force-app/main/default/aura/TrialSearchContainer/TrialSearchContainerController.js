/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        helper.enqueue(component, 'c.getSearchCTPs', {})
            .then(function (data) {
                console.log('data ', data);
                component.set('v.TrialTDOs', data.TrialTDOs);
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
            });
    },
});