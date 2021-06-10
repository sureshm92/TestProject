({
    doExecute: function (component, event, helper) {
        component.find('Show_WarningPoP_Up').show();
        console.log('Date--c>'+component.get('v.fovDate'));
        var fovdt = component.get('v.fovDate');
        if(component.get('v.fovDate') == null || 
           component.get('v.fovTime') == null ||
           component.get('v.fovDate') == '' || 
           component.get('v.fovTime') == '' ){
            component.set('v.isFovnull',true);
        }else{
            component.set('v.isFovnull',false);
        }
        var str = fovdt;
        var res = str.substring(0, 10);
        console.log('Date->'+res);
        
        fovdt = res+'T00:00:00Z';
        component.set('v.fovDate',fovdt);
        component.set('v.backdrop',true);
    },
    doProceed: function (component, event, helper) {
        component.set('v.backdrop',false);
        component.find('Show_WarningPoP_Up').hide();
        var cmpEvent = component.getEvent('cmpEvent');
        cmpEvent.setParams({
            proceed: true
        });
        cmpEvent.fire();
    },
    closepopup: function (component, event, helper) {
        component.set('v.backdrop',false);
        component.find('Show_WarningPoP_Up').hide();
    },
    closefovpopup: function (component, event, helper) {
        component.set('v.backdrop',false);
        component.find('Show_WarningPoP_Up').hide();
    }
});