({
    doMenuExpand: function (component, event, helper) {
        component.set('v.isOpened', true);
        component.getEvent('onshow').fire();
        if ($A.get('$Browser.formFactor') == 'PHONE') {
            var compEvent = component.getEvent('closeNavigationMenu');
            compEvent.fire();
        }
    },

    doMenuCollapse: function (component, event, helper) {
        component.set('v.isOpened', false);
        component.getEvent('onblur').fire();
    },
    doClose: function (component) {
        component.set('v.isOpened', false);
    },

    doOpen: function (component) {
        component.set('v.isOpened', true);
    }
});
