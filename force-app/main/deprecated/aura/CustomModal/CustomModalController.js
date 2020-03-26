/**
 * Created by AlexKetch on 6/18/2019.
 */
({
    show: function (component, event, helper) {
        component.set('v.showModal',true);
    },
    hide: function (component, event, helper) {
        component.set('v.showModal',false);
    },


})