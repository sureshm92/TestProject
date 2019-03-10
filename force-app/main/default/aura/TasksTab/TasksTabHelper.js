/**
 * Created by Leonid Bartenev
 */
({
    updateTasks: function (component, participantTasks) {
        component.set('v.openTasks', participantTasks.openTasks);
        component.set('v.completedTasks', participantTasks.completedTasks);
        component.set('v.myTasks', participantTasks.myTasks);
    }
})