/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doConnect: function(component, event, helper){
    	console.log('hello2');
        var a = component.get('v.healthCareProvider');
    	console.log('a>>>>',a);
    },

    checkFieldsds: function(component, event, helper){
        console.log('change');
        var a = component.get('v.healthCareProvider');
        component.set('v.healthCareProvider', a);
    },
});