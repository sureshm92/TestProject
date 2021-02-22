/**
 * Created by srinath E  on 19-Feb-21.
 */

({
    recordChange: function (component, event, helper) {
        component.set('v.funnelData', null);
        window.setTimeout(
            $A.getCallback(function () {
                helper.getPEFunnelRecord(component, event, helper);
            }),
            100
        );
    }
});