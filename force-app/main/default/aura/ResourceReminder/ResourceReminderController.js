/**
 * Created by Yehor Dobrovolskyi
 */({
    doInit: function (component, event, helper) {
        helper.subscribe(component, event);
        // helper.remind(component, event);
    },

    onRemind: function (component, event, helper) {
        helper.remind(component, event);
    }
})