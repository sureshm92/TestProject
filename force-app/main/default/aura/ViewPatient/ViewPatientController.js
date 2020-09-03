/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            let participantId = communityService.getUrlParameter("id");
            if (!participantId) communityService.navigateToPage('');
            component.set('v.multiMode', communityService.getAllUserModes().length > 1);
            let spinner = component.find('mainSpinner');
            spinner.show();

            communityService.executeAction(component, 'getInitDataForPatientProfile', {
                participantId: participantId,
                mode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
                sponsorName: communityService.getCurrentCommunityTemplateName()
            }, function (response) {
                if (!response) communityService.navigateToPage('');
                let initData = JSON.parse(response);
                component.set('v.participant', initData.participant);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                component.set('v.enrollments', initData.peList);
                console.log('enroll', component.get('v.enrollments'));
                component.set('v.alreadyEnrolled', initData.alreadyEnrolled);
                component.set('v.isInitialized', true);
                //set sticky bar position in browser window
                communityService.setStickyBarPosition();
            }, null, function () {
                spinner.hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});