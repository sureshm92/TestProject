/**
 * Created by dmytro.fedchyshyn on 02.09.2019.
 */

({
    getAvailableVendors: function (component, event, helper) {
        helper.enqueue(component, 'c.getVendors'
            //     {
            //     // userId: component.get('v.recordId')
            // }
        ).then(function (result) {
            console.log(JSON.stringify(result));
            if (result) {
                component.set('v.vendors', result);
                component.set('v.hasVendors', true);
            }
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
        })
    },
});