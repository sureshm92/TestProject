/**
 * Created by Leonid Bartenev
 */
({

    getLabel: function (component, mode, delegateId) {
        var modes = component.get('v.availableModes');
        for(var i = 0; i < modes.length; i++){
            if(modes[i].value === mode && modes[i].delegateId === delegateId) return modes[i].label;
        }
        return '';
    } 

})