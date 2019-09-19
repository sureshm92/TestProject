/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {}, function (response) {
            component.set('v.taskPanelWrapper', response.taskPanelWrapper);
            component.set('v.adHocWrapper', response.adHocWrapper);
            component.set('v.filter', response.filter);
            component.set('v.patientStatusOptions', response.patientStatusOptions);

            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },

    handleActiveTab: function (component, event, helper) {
        component.set('v.selectedTab', event.getSource().get('v.id'));

        var validity = component.get('v.filter.statuses').length > 0;
        validity = helper.checkChild(component, validity);
        component.set('v.isValid', validity);
    },

    checkValid: function (component, event, helper) {
        if (component.get('v.initialized')) {
            var validity = component.get('v.filter.statuses').length > 0;

            var params = event.getParam('arguments');
            if(params) {
                validity = validity && params.childValidity;
            } else {
                validity = helper.checkChild(component, validity);
            }

            component.set('v.isValid', validity);
        }
    },

    createClick: function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'createTasks', {
            'taskPanelWrapper': JSON.stringify(component.get('v.taskPanelWrapper')),
            'adHocWrapper': JSON.stringify(component.get('v.adHocWrapper')),
            'filter': JSON.stringify(component.get('v.filter')),
            'activeTab': component.get('v.selectedTab')
        }, function (response) {
            if (response > 0)
                communityService.showSuccessToast(
                    'Success!',
                    'Task successfully created for ' + response + ' users.'
                );
            else
                communityService.showWarningToast(
                    'Fail!',
                    'No relevant users found in the system'
                );
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    resetClick: function (component, event, helper) {
        helper.reset(component);
    }
});