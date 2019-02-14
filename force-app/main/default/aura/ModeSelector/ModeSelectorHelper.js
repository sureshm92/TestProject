/**
 * Created by Leonid Bartenev
 */
({

    getLabel: function (component, mode) {
        var modes = component.get('v.availableModes');
        for(var i = 0; i < modes.length; i++){
            if(modes[i].value === mode) return modes[i].label;
        }
        return '';
    } 

})