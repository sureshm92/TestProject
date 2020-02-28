/**
 * Created by Leonid Bartenev
 */
({
    doStatusChanged: function (component) {
        debugger;
        var status = component.get('v.status');
        var overrideStatusLabel = component.get('v.overrideStatusLabel');
        if(status){
            if(!overrideStatusLabel){
                var statusParts = status.split('(');
                var statusLabel = statusParts[0];
                //statusLabel = statusLabel.trim();
                component.set('v.statusLabel', statusLabel);
            }
            else{
                component.set('v.statusLabel', overrideStatusLabel);
            }
        }
    }
})