/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getInitData',
            null,
            function (returnValue) {
                var participantItemWithDetails = JSON.parse(returnValue);
                component.set('v.participantItem', participantItemWithDetails.pi);
                component.set('v.referralSourceName',participantItemWithDetails.referralSourceName);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    }
});
