/**
 * Created by Igor Malyuta on 14.04.2019.
 */
({
    doInit : function (component, event, helper) {
        communityService.executeAction(component, 'getVisitsLegend', null, function (response) {
            component.set('v.legends', JSON.parse(response));
            component.find('spinner').hide();
        });
    }
})