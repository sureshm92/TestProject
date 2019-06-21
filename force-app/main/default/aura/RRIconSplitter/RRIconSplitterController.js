/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit: function (component, event, helper) {
        var value = component.get('v.value');
        let splitted = [];
        if (value) {
            splitted = value.split(';');
            let icons = component.get('v.icons');
            if (!icons || icons.length == 0) {
                let icons = [];
                let numOfIconsToDisplay = component.get('v.numOfIconsToDisplay');
                if(numOfIconsToDisplay == 0) {
                    icons = splitted;
                }
                else {
                    var size = splitted.length < numOfIconsToDisplay ? splitted.length : numOfIconsToDisplay;
                    if(size < numOfIconsToDisplay) component.set('v.numOfIconsToDisplay', 0);
                    for(var i = 0; i < size; i++) icons.push(splitted[i]);
                }
                component.set('v.icons', icons);
            }
        }
    }
})
