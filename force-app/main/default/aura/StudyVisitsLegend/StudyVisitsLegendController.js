/**
 * Created by Igor Malyuta on 14.04.2019.
 */
({
    doInit : function (component, event, helper) {
        communityService.executeAction(component, 'getVisitsLegend', {
            'iconNames' : component.get('v.iconNames')
        }, function (response) {
            component.set('v.legends', JSON.parse(response));
        });
    }
})