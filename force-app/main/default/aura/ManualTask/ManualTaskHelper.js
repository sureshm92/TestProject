/**
 * Created by user on 11.03.2019.
 */
({
    reset : function (component) {
        $A.enqueueAction(component.get('c.doInit'));
    },

    setDays : function (component) {
        $A.enqueueAction(component.get('c.remindDaysReduce'));
    }
})