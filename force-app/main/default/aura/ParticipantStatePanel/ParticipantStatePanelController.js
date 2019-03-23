/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component,
            'getInitData',
            null,
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                component.set('v.pe', initData.participantState.pe);
                component.set('v.pse', initData.participantState.pse);
                component.set('v.psePath', initData.psePath);
            }, null, function () {
                component.find('spinner').hide();
            });
    }
})