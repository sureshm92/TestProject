/**
 * Created by user on 12.04.2019.
 */
({
    doInit : function (component, event, helper) {
        var toSplit = component.get('v.value');
        component.set('v.icons', toSplit.split(';'));
    }
})