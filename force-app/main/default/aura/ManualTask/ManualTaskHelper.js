/**
 * Created by user on 11.03.2019.
 */
({
    reset : function (component) {
        $A.enqueueAction(component.get('c.doInit'));
    },

    addDays : function (component) {
        $A.enqueueAction(component.get('c.dueDateAdd'));
    }
})