/**
 * Created by Nikita Abrazhevitch on 11-Sep-19.
 */

({
    doInit: function(component, event, helper){
    	var result = component.get('v.results');
    	if(!result.includes('http')){
    	    component.set('v.decodeResults',  atob(result));
        }
    },
});