/**
 * Created by AlexKetch on 6/21/2019.
 */
({
    getIconsDescription: function (component, event, helper) {
        helper.enqueue(component, 'c.getIconsDescription', {
            visitPlanId: component.get('v.visitPlanId')
        }).then(function (result) {
            component.set('v.detailIcons', result)
        }, function (err) {
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
    onSubmit: function (component, event, helper) {
        let iconsDetail = component.get('v.detailIcons');
        helper.enqueue(component,'c.saveIconInfo', {
            'iconsDetails': iconsDetail,
        }).then(function () {
            component.find('customModal').hide();
            helper.notify({
                "title": "Success!",
                "message": "saved successfully.",
                "type": 'success'
            });
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
            component.find('customModal').hide();
        });
        component.find('customModal').hide();
    },




})