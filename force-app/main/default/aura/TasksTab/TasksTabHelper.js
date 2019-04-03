/**
 * Created by Leonid Bartenev
 */
({
    updateTasks: function (component, participantTasks) {
        component.set('v.openTasks', participantTasks.openTasksWrapper);
        component.set('v.completedTasks', participantTasks.completedTasks);
    }
})