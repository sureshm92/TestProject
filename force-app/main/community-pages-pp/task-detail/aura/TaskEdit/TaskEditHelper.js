/**
 * Created by Igor Malyuta on 26.07.2019.
 */

({
    updateStatus : function (component, method) {
        component.find('spinner').show();
        communityService.executeAction(component, method, {
            'taskId': component.get('v.task').Id
        }, function () {
            window.history.go(-1);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    isSameDay : function (component) {
        var today = component.get('v.todayDate');
        var dueDate = component.get('v.initData.activityDate');
        dueDate = moment(dueDate, 'YYYY-MM-DD');

        return dueDate.isSame(today);
    }
});