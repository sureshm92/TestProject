/**
 * Created by Igor Malyuta on 11.03.2019.
 */
({
    reset : function (component) {
        $A.enqueueAction(component.get('c.doInit'));
    },

    setDays : function (component) {
        $A.enqueueAction(component.get('c.onDaysChange'));
    },
    
    getDaysBetween: function (component, startDate, dueDate) {
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds

        return Math.round(
            Math.abs((startDate.getTime() - dueDate.getTime()) / oneDay)
        );
    }
})