/**
 * Created by Igor Malyuta on 11.03.2019.
 */
({
    setDays : function (component) {
        $A.enqueueAction(component.get('c.onDaysChange'));
    }
});