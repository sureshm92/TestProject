/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit : function (component, event, helper) {
        var toSplit = component.get('v.value');
        var icons = [];
        if(!component.get('v.hideMoreThan3')) {
            icons = toSplit.split(';');
        }
        else {
            var splitted = toSplit.split(';');
            for(var i = 0; i < 3; i++) icons.push(splitted[i]);
        }
        component.set('v.icons', icons);
    }
})