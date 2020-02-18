/**
 * Created by Igor Malyuta on 12.04.2019.
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        var opts = [
            {value: "All", label: $A.get("$Label.c.Home_Page_VisitTab_Filter_Show_All")},
            {value: "Current", label: $A.get("$Label.c.Home_Page_StudyVisit_Filter_Current_Visits")},
            {value: "Past", label: $A.get("$Label.c.Home_Page_StudyVisit_Filter_Past_Visits")}];
        component.set('v.options', opts);
        communityService.executeAction(component, 'isStudySiteHasVisits', {},
            function (response) {
                if (!response) {
                    component.set('v.isHasVisits', response);
                    component.set('v.initialized', true);
                } else $A.enqueueAction(component.get('c.getVisits'));
            });
        component.find('spinner').hide();
    },

    getVisits: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getParticipantVisits', {
            'visitMode': component.get('v.visitMode')
        }, function (response) {
            component.set('v.visitWrappers', response);
            let iconNames = '';
            for (let i = 0; i < response.length; i++) {
                iconNames += response[i].icons + ';';
            }
            component.set('v.iconNames', iconNames);
            component.set('v.initialized', true);
        });
        component.find('spinner').hide();
    },

    onTravel: function (component, event, helper) {
        component.find('showVendors').show();
    },

    closeModal: function (component, event, helper) {
        component.find('showVendors').hide();
    },

    createEditTask: function (component, event, helper) {
        let taskId = event.currentTarget.dataset.taskId;
        let visitId = event.currentTarget.dataset.visitId;
        if (!taskId) {
            communityService.navigateToPage('task-detail?visitId=' + visitId);
        } else {
            communityService.navigateToPage('task-detail?id=' + taskId + '&visitId=' + visitId);
        }
    }
});