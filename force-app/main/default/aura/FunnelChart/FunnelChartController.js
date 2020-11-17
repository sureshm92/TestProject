/**
 * Created by Nikita Abrazhevitch on 13-Feb-20.
 * Modified by Sabir on 20-oct-20. 
 */

({  
    recordChange: function(component, event, helper)
    {
      component.set('v.funnelData', null);
      window.setTimeout
      (
            $A.getCallback(function() {
                helper.getPEFunnelRecord(component, event, helper);
            }), 100
      );

    },
        
});