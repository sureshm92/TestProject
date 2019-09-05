/**
 * Created by Leonid Bartenev
 */
({
    doMenuExpand: function(component, event, hepler){
        component.set('v.isOpened', true);
    },

    doMenuCollapse: function (component, event,halper) {
        component.set('v.isOpened', false);
    },

    doClose: function(component){
        component.set('v.isOpened', false);
    },

    doOpen: function(component){
        component.set('v.isOpened', true);
    }


})