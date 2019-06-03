/**
 * Created by Igor Malyuta on 30.05.2019.
 */

({
    reload : function (component) {
        $A.enqueueAction(component.get('c.doInit'));
    }
});