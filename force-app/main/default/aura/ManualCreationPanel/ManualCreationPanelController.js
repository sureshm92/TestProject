/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {}, function (response) {
            component.set('v.taskPanelWrapper', response.taskPanelWrapper);
            component.set('v.taskConfig', response.taskPanelWrapper.taskConfig);
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
            config: JSON.stringify(component.get('v.taskConfig')),
            adHocWrapper: component.get('v.adHocWrapper'),
            filter: component.get('v.filter'),
            activeTab: component.get('v.selectedTab')
        }, function (found) {
            if (found)
                communityService.showSuccessToast(
                    'Success!',
                    'Creation process is launched!'
                );
            else
                communityService.showWarningToast(
                    'Fail!',
                    'No relevant users are found in the system!'
                );
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    resetClick: function (component, event, helper) {
        helper.reset(component);
    }
});