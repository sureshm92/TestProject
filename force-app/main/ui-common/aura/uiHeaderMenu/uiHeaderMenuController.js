/**
 * Created by Leonid Bartenev
 */
({
    doMenuExpand: function(component, event, helper){
        component.set('v.isOpened', true);
    },

    doMenuCollapse: function (component, event, helper) {
        component.set('v.isOpened', false);
    },

    doClose: function(component){
        component.set('v.isOpened', false);
    },

    doOpen: function(component){
        component.set('v.isOpened', true);
    }

});