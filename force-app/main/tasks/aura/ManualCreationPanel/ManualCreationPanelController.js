/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    loadRecord: function(component, helper) {
        console.log('loadRecord');
        $A.get('e.force:refreshView').fire();
        /*var a = component.get('c.doInit');
        $A.enqueueAction(a);*/
    },
    removeRecc: function(component, event, helper) {
        component.set('v.isOpen', true);
        /*var evt = $A.get('e.force:navigateToComponent');
        console.log('Event ' + evt);
        var accountFromId = component.get('v.recordId');
        evt.setParams({
            componentDef: 'c:RemoveRecurrenceButton',
            componentAttributes: {
                recordId: component.get('v.pageReference').state.c__id
            }
        });

        evt.fire();*/
    },
    closeModel: function(component, event, helper) {
        component.set('v.isOpen', false);
    },
    doInit: function(component, event, helper) {
        var recordId = component.get('v.pageReference').state.c__id;
        console.log('Here is record Id' + recordId);
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {}, function(response) {
            component.set('v.taskPanelWrapper', response.taskPanelWrapper);
            component.set('v.adHocWrapper', response.adHocWrapper);
            component.set('v.taskConfig', response.taskPanelWrapper.taskConfig);
            component.set('v.filter', response.filter);
            component.set('v.patientStatusOptions', response.patientStatusOptions);

            component.set('v.initialized', true);
            if (recordId) {
                component.set('v.recordId', recordId);
                component.set('v.isEdit', true);
                communityService.executeAction(
                    component,
                    'getTaskData',
                    { recId: recordId },
                    function(response2) {
                        component.set('v.mcpt', response2);
                        var mcptEdit = component.get('v.mcpt');
                        if (
                            !mcptEdit.Is_Recurrence__c &&
                            mcptEdit.Last_Occurrence_Date__c != null
                        ) {
                            component.set('v.oneTimeTaskInProgress', true);
                        }
                        component.set('v.taskConfig', JSON.parse(response2.TaskConfig__c));
                        component.set('v.filter', JSON.parse(response2.TaskFilter__c)); //
                        component.set('v.remDays', response2.Reminder_days_before_due_date__c);
                    }
                );
            }
            component.find('spinner').hide();
        });
    },

    handleActiveTab: function(component, event, helper) {
        component.set('v.selectedTab', event.getSource().get('v.id'));

        var validity = component.get('v.filter.statuses').length > 0;
        validity = helper.checkChild(component, validity);
        component.set('v.isValid', validity);
    },
    checkSaveValid: function(component, event, helper) {
        if (component.get('v.initialized')) {
            var valid = component.get('v.filter.statuses').length > 0;
            valid = helper.checkChildSave(component, valid);
        }
        component.set('v.isValidSave', valid);
    },
    checkValid: function(component, event, helper) {
        if (component.get('v.initialized')) {
            var validity = component.get('v.filter.statuses').length > 0;

            var params = event.getParam('arguments');
            if (params) {
                validity = validity && params.childValidity;
            } else {
                validity = helper.checkChild(component, validity);
            }

            component.set('v.isValid', validity);
        }
    },

    createClick: function(component, event, helper) {
        component.find('spinner').show();
        console.log('remind: ' + component.get('v.taskConfig').reminderDate);

        if (component.get('v.mcpt') != null) {
            // add/remove recurrence validation
            if (
                component.get('v.mcpt').Is_Recurrence__c !=
                    component.get('v.taskConfig').isRecurrence &&
                component.get('v.mcpt').Last_Occurrence_Date__c != null
            ) {
                communityService.showWarningToast(
                    'Fail!',
                    'Cannot add or remove recurrence for In Progress task'
                );
                component.find('spinner').hide();
                return;
            }
            if (
                component.get('v.mcpt').Start_Date__c != component.get('v.taskConfig').startDate &&
                component.get('v.taskConfig').startDate <=
                    $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD')
            ) {
                // start date cannot be changed to past or today's date
                communityService.showWarningToast(
                    'Fail!',
                    "New start date should be greater than today's date"
                );
                component.find('spinner').hide();
                return;
            }
        }
        communityService.executeAction(
            component,
            'createTasks',
            {
                config: JSON.stringify(component.get('v.taskConfig')),
                adHoc: JSON.stringify(component.get('v.adHocWrapper')),
                filter: JSON.stringify(component.get('v.filter')),
                activeTab: component.get('v.selectedTab'),
                mcpt: component.get('v.mcpt')
            },
            function(found) {
                console.log('found: ' + found);
                if (found) {
                    console.log('found: ' + found);
                    if (found != null && found != '') {
                        if (component.get('v.pageReference').state.c__id) {
                            communityService.showSuccessToast('Success!', 'Task is Updated!');
                        } else {
                            communityService.showSuccessToast(
                                'Success!',
                                'Creation process is launched!'
                            );
                        }
                        var action = component.get('c.getListViews');
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === 'SUCCESS') {
                                var listviews = response.getReturnValue();
                                var navEvent = $A.get('e.force:navigateToList');
                                navEvent.setParams({
                                    listViewId: listviews.Id,
                                    listViewName: null,
                                    scope: 'Manual_Creation_Panel_Task__c'
                                });
                                navEvent.fire();
                            }
                        });
                        $A.enqueueAction(action);
                    }
                } else
                    communityService.showWarningToast(
                        'Fail!',
                        'No relevant users are found in the system!'
                    );
            },
            null,
            function() {
                component.find('spinner').hide();
            }
        );
    },
    navigateToRecord: function(component, event, helper) {
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            url: '/lightning/n/Manual_Creation_Panel?c__id=' + component.get('v.recordId')
        });
        urlEvent.fire();
    },

    resetClick: function(component, event, helper) {
        helper.reset(component);
    }
});
