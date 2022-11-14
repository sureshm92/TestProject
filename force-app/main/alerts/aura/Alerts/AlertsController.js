/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        component.find('onboardingSlideTour').refresh();
        communityService.executeAction(
            component,
            'getAlerts',
            {
                userMode: communityService.getUserMode()
            },
            function (returnValue) {
                let alerts = JSON.parse(returnValue);
                component.set('v.alerts', alerts);
                let currentAlertIndex = 0;
                component.set('v.currentAlertIndex', currentAlertIndex);
                if (alerts.length > 0) {
                    component.set('v.currentAlert', alerts[currentAlertIndex]);
                    if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                        component.find('alertsDialog').show();
                    }
                } else {
                    if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                        component.find('onboardingSlideTour').initialShow();
                    }
                    component.find('motivationalMessages').show();
                }
            }
        );
    },

    doShowNext: function (component) {
        let currAlert = component.get('v.currentAlert');
        if (currAlert) {
            communityService.executeAction(component, 'setAlertViewed', {
                alertId: currAlert.id
            });
        }
        let currentAlertIndex = component.get('v.currentAlertIndex') + 1;
        let alerts = component.get('v.alerts');
        console.log(
            'alerts.length = ' + alerts.length + ' for that alerts: ' + JSON.stringify(alerts)
        );
        let popup = component.find('alertsDialog');
        if (currentAlertIndex < alerts.length) {
            component.set('v.currentAlertIndex', currentAlertIndex);
            component.set('v.currentAlert', alerts[currentAlertIndex]);
            if (popup) popup.show();
        } else {
            if (popup) popup.set('v.showModal', false);
            component.set('v.currentAlert', null);
            console.log('Current alert ' + component.get('v.currentAlert'));
            component.find('onboardingSlideTour').initialShow();
            component.find('motivationalMessages').show();
        }
    }
});
