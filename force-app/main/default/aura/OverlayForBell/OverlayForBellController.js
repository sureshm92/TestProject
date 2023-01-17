({
    doMenuExpand: function (component, event, helper) {
        if(!component.get('v.isOpened')) {
            component.set('v.isOpened', true);
            component.getEvent('onshow').fire();
        }
    },

    doMenuCollapse: function (component, event, helper) {
        if(component.get('v.isOpened')) {
        	component.set('v.isOpened', false);
            var compEvent = component.getEvent("onBlurOverlayBellEvent");
            compEvent.fire();
        }
    },

    doClose: function (component) {
        component.set('v.isOpened', false);

    },

    doOpen: function (component) {
        component.set('v.isOpened', true);
    },

    closeBell : function(component,event, helper){
        if(component.get('v.isOpened')) {
        	component.set('v.isOpened', false);
            var compEvent = component.getEvent("onBlurOverlayBellEvent");
            compEvent.fire();
        }
    }
});