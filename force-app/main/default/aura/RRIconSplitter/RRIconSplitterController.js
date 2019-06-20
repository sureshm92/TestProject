/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit: function (component, event, helper) {
        var value = component.get('v.value');
        let splitted = [];
        if (value) {
            splitted = splitted.split(';');
            let icons = component.get('v.icons');
            if (!icons || icons.length == 0) {
                let icons = [];
                if (!component.get('v.hideMoreThan3')) {
                    icons = splitted;
                }
                else {
                    var size = splitted.length < 3 ? splitted.length : 3;
                    if (size < 3) component.set('v.hideMoreThan3', false);
                    for (var i = 0; i < size; i++) icons.push(splitted[i]);
                }
                component.set('v.icons', icons);
            }
        }
    }
})