/**
 * Created by dmytro.fedchyshyn on 02.09.2019.
 */

({
    createStudyVisitReminder: function (component, visitWrapper) {
        component.find('spinner').show();
        //var title = $A.util.isUndefinedOrNull(visitWrapper.task)
        //  ? $A.get('$Label.c.PP_Create_Visit_Reminder')
        //: $A.get('$Label.c.PP_Edit_Visit_Reminder');
        var title ;
        if(visitWrapper.visit.Visit__c){
            title = !visitWrapper.visit.Portal_Name__c ? visitWrapper.visit.Visit__r.Patient_Portal_Name__c:visitWrapper.visit.Visit__r.Name;
        }
        else{
            title = visitWrapper.visit.Portal_Name__c;
        }
        var isNewTask = $A.util.isUndefinedOrNull(visitWrapper.task) ? true : false;
        $A.createComponent(
            'c:StudyVisitReminder',
            {
                'aura:id': 'studyVisitReminder',
                visitId: visitWrapper.visit.Id,
                taskId: $A.util.isUndefinedOrNull(visitWrapper.task) ? null : visitWrapper.task.Id,
                title: title + ' ' + $A.get('$Label.c.PP_Details'),
                taskType: 'Visit',
                visitData: visitWrapper,
                isNewTask: isNewTask,
                isReminderOnly: true,
                parent: component.get('v.cmpDef'),
                reRender:true
            },
            function (reminder, status, errorMessage) {
                if (component.isValid() && status === 'SUCCESS') {
                    let visitReminder = component.find('visitReminder');
                    let body = visitReminder.get('v.body');
                    body.push(reminder);
                    visitReminder.set('v.body', body);
                    component.set('v.firstLoad', true);
                    component.find('spinner').hide();
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
    }
});