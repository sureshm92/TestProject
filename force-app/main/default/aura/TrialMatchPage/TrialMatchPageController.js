/**
 * Created by Sravani Dasari
 */
({
    doInit: function (component, event, helper) {
        component.find('mainSpinner').show();
        helper.enqueue(component, 'c.getMatchCTPs', {})
            .then(function (data) {
                console.log('data ', data);
                component.set('v.trialmatchCTPs', data.trialmatchctps);
                component.set('v.initializedTrms', true);
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
            String.format = function (format) {
                var args = Array.prototype.slice.call(arguments, 1);
                return format.replace(/{(\d+)}/g, function (match, number) {
                    return typeof args[number] != 'undefined' ? args[number] : match;
                });
            };
        }
    }
});