/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getPreviewTasks', null, function (tasks) {
            component.set('v.tasks', tasks);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doTaskClick: function (component, event, helper) {
        let index = event.currentTarget.dataset.index;
        let taskData = component.get('v.tasks')[index];        
        let taskId = taskData.Id;
        let actionURL = taskData.Action_URL__c;
        let firstLoad = component.get('v.firstLoad');
        let title = $A.get('$Label.c.TTL_Edit_Task');
        if(!$A.util.isUndefinedOrNull(actionURL)){
            communityService.executeAction(component, 'taskClicked', {
                id: taskId,
                message: actionURL
            }, function(){
                communityService.navigateToPage(actionURL);
            }, null, null);
        } else if(!firstLoad){
            //function (component, title, taskData, isReminderOnly)            
            helper.createStudyVisitReminder(component, title, taskData, false);
        } else{
            //function(component, taskData, title, isOpenTask, isReminderOnly)            
            component.find('studyVisitReminder').reloadPopup(helper.setReloadAttributes(component, taskData, title, true, false));
        }
    }
});