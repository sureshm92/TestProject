/**
 * Created by user on 01.03.2019.
 */
({
    doInit : function(component, event, helper) {
      communityService.executeAction(component, 'getInitData', null, function (returnValue) {
          var initData = JSON.parse(returnValue);
          component.set('v.priorities', initData.priorities);
      });
    },

    dueDateAdd : function(component, event, helper) {
        communityService.executeAction(component, 'addDays', {
            'dateStart' : component.get('v.task.Start_Date__c'),
            'count' : component.get('v.dayDue')
        }, function (response) {
            component.set('v.task.ActivityDate', response);
        });
    },

    dueDateValid : function(component, event, helper) {
        communityService.executeAction(component, 'checkAndGetValidDate', {
            'start' : component.get('v.task.Start_Date__c'),
            'due' : component.get('v.task.ActivityDate')
        }, function (response) {
            component.set('v.task.ActivityDate', response.getReturnValue());
        });
    },

    createTask : function (component, event, helper) {
        console.log('Subj is ' + component.get('v.task.Subject'));
        console.log('Start date is ' + component.get('v.task.Start_Date__c'));
        console.log('Due date is ' + component.get('v.task.ActivityDate'));
        console.log('Selected areas ' + component.get('v.areas'));

        communityService.executeAction(component, 'createTasks', {
            'task' : component.get('v.task'),
            'selectedStatus' : component.get('v.status'),
            'filter' : component.get('v.taskFilters')
        }, function (response) {
            //show popup
        });
    },

    backAction : function (component, event, helper) {
        //Cancel click
    }
})