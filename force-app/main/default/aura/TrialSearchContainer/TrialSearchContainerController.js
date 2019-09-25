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
                component.set('v.participant', data.participant);
                component.set('v.formData', data.formData);
                component.set('v.isInit', true);
                component.find('mainSpinner').hide();
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                component.find('mainSpinner').hide();
            }).catch(function (err) {
            console.error(err);
            component.find('mainSpinner').hide();
        });
        if (!String.format) {
            String.format = function(format) {
                var args = Array.prototype.slice.call(arguments, 1);
                return format.replace(/{(\d+)}/g, function(match, number) {
                    return typeof args[number] != 'undefined' ? args[number] : match;
                });
            };
        }
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
                component.set('v.isInit', true);
                // component.set('v.taps', data.taps);
                component.find('mainSpinner').hide();
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                component.find('mainSpinner').hide();
            }).catch(function (err) {
            console.error(err);
            component.find('mainSpinner').hide();
        });
    }
});