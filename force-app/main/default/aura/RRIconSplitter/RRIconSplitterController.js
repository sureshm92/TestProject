/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit: function (component, event, helper) {
        var value = component.get('v.value');
        if (value) component.set('v.icons',value.split(';'));
    }
});