/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if (!communityService.isInitialized()) return;
        var participantId = communityService.getUrlParameter("id");
        if(!participantId) communityService.navigateToPage('');
        component.set('v.multiMode', communityService.getCommunityTypes().length > 1);
        var spinner = component.find('mainSpinner');
        spinner.show();

        var action = component.get('c.getInitDataForPatientProfile');
        action.setParams({
            participantId: participantId,
            mode: communityService.getUserMode()
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                if(!response.getReturnValue()) communityService.navigateToPage('');
                var initData = JSON.parse(response.getReturnValue());
                component.set('v.participant', initData.participant);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                component.set('v.enrollments', initData.peList);
                component.set('v.alreadyEnrolled', initData.alreadyEnrolled);
                component.set('v.isInitialized', true);
                //set sticky bar position in browser window
                communityService.setStickyBarPosition();

            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            spinner.hide();
        });
        $A.enqueueAction(action);

    }
})