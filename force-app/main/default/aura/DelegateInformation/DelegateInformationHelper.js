/**
 * Created by Igor Malyuta on 25.03.2019.
 */
({
    doLogOut : function (component) {
        communityService.executeAction(component, 'getLogOutUrl', null,
            function (returnValue) {
                window.location.replace(returnValue + '/secur/logout.jsp');
            }, function (error) {
                communityService.showToast("error", "error", $A.get('$Label.c.TST_Something_went_wrong'));
                communityService.logErrorFromResponse(error);
            }
        );
    }
})