/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component,
            'getInitData',
            null,
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                component.set('v.pe', initData.pe);
            });
    }
})