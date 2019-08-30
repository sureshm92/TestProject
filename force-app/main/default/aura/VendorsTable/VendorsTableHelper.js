/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    getAvailableVendors: function (component, event, helper) {
        helper.enqueue(component, 'c.getVendors'
            //     {
            //     // userId: component.get('v.recordId')
            // }
        ).then(function (result) {
            console.log(JSON.stringify(result));
            component.set('v.vendors', result)
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