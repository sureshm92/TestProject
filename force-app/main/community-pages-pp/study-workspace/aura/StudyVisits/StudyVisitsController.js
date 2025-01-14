/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        var opts = [
            { value: 'All', label: $A.get('$Label.c.Home_Page_VisitTab_Filter_Show_All') },
            { value: 'Scheduled', label: $A.get('$Label.c.PP_Scheduled')},
            {
                value: 'Pending',
                label: $A.get('$Label.c.Home_Page_StudyVisit_Filter_Current_Visits')
            },
            { value: 'Past', label: $A.get('$Label.c.Home_Page_StudyVisit_Filter_Past_Visits') }
            
        ];
        component.set('v.options', opts);
        communityService.executeAction(component, 'isStudySiteHasVisits', {}, function (response) {
            if (!response) {
                component.set('v.isHasVisits', response);
                component.set('v.initialized', true);
            } else $A.enqueueAction(component.get('c.getVisits'));
        });
        component.find('spinner').hide();
    },

    getVisits: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getParticipantVisits',
            {
                visitMode: component.get('v.visitMode')
            },
            function (response) {
                component.set('v.visitWrappers', response);
                console.log('wrappers-->',response);
                let iconNames = '';
                for (let i = 0; i < response.length; i++) {
                    iconNames += response[i].icons + ';';
                }
                component.set('v.iconNames', iconNames);
                component.set('v.initialized', true);
            }
        );
        component.find('spinner').hide();
    },

    onTravel: function (component, event, helper) {
        component.find('showVendors').show();
    },

    closeModal: function (component, event, helper) {
        component.find('showVendors').hide();
    },

    reloadTable: function (component, event, helper) {
        var rrPage = component.find('rrPaginationComponent');
        component.set('v.pageNumber', rrPage.PageNumer());
        component.set('v.pageCheck', rrPage.PageNumer() > 1);
        $A.enqueueAction(component.get('c.doInit'));
    },

    createEditTask: function (component, event, helper) {
        var currentVisits = component.get('v.currentVisits');
        var indexVar = event.getSource().get('v.value');
        var visitWrapper = currentVisits[indexVar];
        var firstLoad = component.get('v.firstLoad');
        component.set('v.firstLoad',false);
        //if (!firstLoad) {
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
                reRender :true
            };
            component.find('studyVisitReminder').reloadPopup(relaodAttributes);
        }*/
    }
});