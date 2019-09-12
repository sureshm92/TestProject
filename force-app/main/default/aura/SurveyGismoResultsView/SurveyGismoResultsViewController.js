/**
 * Created by Nikita Abrazhevitch on 11-Sep-19.
 */

({
    doInit: function(component, event, helper){
    	var result = component.get('v.results');
    	if(!result.includes('http')){
    	    var data = atob(result);
    	    data = data.replace('<h1>', '<h1 class="hide-survey-header">');
    	    component.set('v.decodeResults',  data);
        }
    },
});