({
    doMenuExpand: function (component, event, helper) {
        component.set('v.isOpened', true);
        component.getEvent('onshow').fire();
    },

    doMenuCollapse: function (component, event, helper) {
        component.set('v.isOpened', false);
        let blurEvent = component.getEvent('onblur');
        blurEvent.setParams({
            "message" : "onblur","identifier":"sitecal" });
        blurEvent.fire();
        var compEvent = component.getEvent("sampleComponentEvent");
        compEvent.fire();
        //component.getEvent('onblur').fire();
    },

    doClose: function (component) {
        component.set('v.isOpened', false);
        
    },

    doOpen: function (component) {
        component.set('v.isOpened', true);
    }
});