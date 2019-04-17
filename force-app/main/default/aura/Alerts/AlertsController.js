/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        var userMode = component.get('v.userMode');
        if(userMode){
            communityService.executeAction(component, 'getAlerts', {
                userMode: userMode
            }, function (returnValue) {
                var alerts = JSON.parse(returnValue);
                component.set('v.alerts', alerts);
                var currentAlertIndex = 0;
                component.set('v.currentAlertIndex', currentAlertIndex);
                if(alerts.length > 0) {
                    component.set('v.currentAlert', alerts[currentAlertIndex]);
                    component.find('alertsDialog').show();
                }else{
                    component.find('onboardingSlideTour').initialShow();
                    component.find('motivationalMessages').show();
                }
            });
        }
    },

    doShowNext: function (component) {
        var currAlert = component.get('v.currentAlert');
        if(currAlert){
            communityService.executeAction(component, 'setAlertViewed', {
                alertId: currAlert.id
            });
        }
        var currentAlertIndex = component.get('v.currentAlertIndex') + 1;
        var alerts = component.get('v.alerts');
        if(currentAlertIndex < alerts.length){
            component.set('v.currentAlertIndex', currentAlertIndex);
            component.set('v.currentAlert', alerts[currentAlertIndex]);
            component.find('alertsDialog').show();
        }else{
            component.find('alertsDialog').set('v.showModal', false);
            component.set('v.currentAlert', null);
            component.find('onboardingSlideTour').initialShow();
            component.find('motivationalMessages').show();
        }
    }
})