/**
 * Created by Alexey Moseev.
 */
({  
    recordChange : function(component, event, helper)
    {
        component.set('v.peList', null);
        window.setTimeout(
            $A.getCallback(function() {
                helper.loadData(component, event, helper); 
            }), 100
        );
    },
})