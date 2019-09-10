/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        component.find('mainSpinner').show();
        helper.enqueue(component, 'c.getSearchCTPs', {})
            .then(function (data) {
                console.log('data ', data);
                component.set('v.trialTDOs', data.trialTDOs);
                component.set('v.taps', data.taps);
                component.find('mainSpinner').hide();
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                component.find('mainSpinner').hide();
            });
    },

    handleUpdateSearchEvent : function (component, event, helper) {
        component.find('mainSpinner').show();
        let taps = event.getParam('settings');
        let isEnrolling = event.getParam('enrolling');
        let isNotYetEnrolling = event.getParam('notYetEnrolling');
        helper.enqueue(component, 'c.getFilterSearchCTPs', {
            'taps' : taps,
            'isEnrolling' : isEnrolling,
            'isNotYetEnrolling' : isNotYetEnrolling
        })
            .then(function (data) {
                console.log('data ', data);
                component.set('v.trialTDOs', data.trialTDOs);
                // component.set('v.taps', data.taps);
                component.find('mainSpinner').hide();
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                component.find('mainSpinner').hide();
            });
    }
});