/**
 * Created by Nargiz Mamedova on 1/9/2020.
 */

({
    resetForm: function (component) {
        component.set('v.hideForm', true);
        setTimeout(
            $A.getCallback(function () {
                component.set('v.hideForm', false);
            }), 100
        );
    }
});