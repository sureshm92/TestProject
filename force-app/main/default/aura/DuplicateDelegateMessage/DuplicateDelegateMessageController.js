/**
 * Created by Nikita Abrazhevitch on 13-Jun-20.
 */

({
    doOnClick: function (component, event, helper) {
        component.getEvent('ddMessageButtonClick').fire();
    },
});