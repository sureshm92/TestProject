/**
 * Created by Nikita Abrazhevitch on 19-Sep-19.
 */

({
    doInit: function(component, event, helper){
    	var pe = component.get('v.pe');
    	if(pe && !pe.healthCareProviders){
    	    var healthcare = [{Email:'test@email.test', First_Name:'Test', LastName:'Name'}];
    	    pe.healthCareProviders = healthcare;
    	    component.set('v.pe',pe);
        }
        for (let i = 0, j = pe.healthCareProviders.length; i < j; i++) {
            $A.createComponent(
                'c:ReferHealthcareProviderForm',
                {
                    'healthCareProvider': component.getReference('v.pe.healthCareProviders['+i+']')
                },
                function(cmp,status,errorMessage){
                    if(status=='SUCCESS'){
                        var body = component.get('v.body');
                        body.push(cmp);
                        component.set('v.body',body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
                }
            )
        }
    },

    doAddProvider: function(component, event, helper){
        var pe = component.get('v.pe');
        var healthcare = {Email:null, First_Name:null, LastName:null};
        pe.healthCareProviders.push(healthcare);
        var i = pe.healthCareProviders.length-1;
        component.set('v.pe',pe);
        $A.createComponent(
            'c:ReferHealthcareProviderForm',
            {
                'healthCareProvider': component.getReference('v.pe.healthCareProviders['+i+']')
            },
            function(cmp,status,errorMessage){
                if(status=='SUCCESS'){
                    var body = component.get('v.body');
                    body.push(cmp);
                    component.set('v.body',body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        )
    },
});