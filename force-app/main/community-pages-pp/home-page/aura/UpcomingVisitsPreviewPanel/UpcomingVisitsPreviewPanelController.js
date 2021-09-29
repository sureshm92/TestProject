/**
 * Created by Igor Malyuta on 08.04.2019.
 */
({
    doInit: function (component, event, helper) {
        if (communityService) {
            communityService.executeAction(component, 'getVisitsPreview', null, function (
                response
            ) {
                component.set('v.visitWrappers', response);
                component.set('v.initialized', true);
                component.find('spinner').hide();
            });
            communityService.executeAction(component, 'getIsVisitPathEnabled', null, function (
                response
            ) {
                component.set('v.isVisitPathEnabled', response);
                component.find('spinner').hide();
            });
        }
    },

    closeModal: function (component, event, helper) {
        component.find('showVendors').hide();
    },
    createEditTask: function (component, event, helper) {
        var currentVisits = component.get('v.visitWrappers');
        var indexVar = event.getSource().get('v.value');
        var visitWrapper = currentVisits[indexVar];
        var firstLoad = component.get('v.firstLoad');

        // if (!firstLoad) {
        helper.createStudyVisitReminder(component, visitWrapper);
        /*} else {
            //var title = $A.util.isUndefinedOrNull(visitWrapper.task)
              //  ? $A.get('$Label.c.PP_Create_Visit_Reminder')
                //: $A.get('$Label.c.PP_Edit_Visit_Reminder');
            var title = !visitWrapper.visit.Portal_Name__c?visitWrapper.visit.Visit__r.Patient_Portal_Name__c:visitWrapper.visit.Visit__r.Name;
            var isNewTask = $A.util.isUndefinedOrNull(visitWrapper.task) ? true : false;
            var relaodAttributes = {
                visitId: visitWrapper.visit.Id,
                taskId: $A.util.isUndefinedOrNull(visitWrapper.task) ? null : visitWrapper.task.Id,
                title: title + ' ' + $A.get('$Label.c.PP_Details'),
                taskType: 'Visit',
                visitData: visitWrapper,
                isNewTask: isNewTask,
                isReminderOnly: true,
                parent: component.get('v.cmpDef'),
                reRender:true,
                isUpcomingVisits:true
            };
            component.find('studyVisitReminder').reloadPopup(relaodAttributes);
        }*/
    }
});
