/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            // spinner.show();
            if (communityService.getUserMode() === 'Participant')
                communityService.navigateToPage('');
            component.set('v.userMode', communityService.getUserMode());

            let ctpId = null;
            let piId = null;
            if (component.get('v.piData')) {
                if (component.get('v.piData.selectedCTP'))
                    ctpId = component.get('v.piData.selectedCTP');
                if (component.get('v.piData.selectedPi'))
                    piId = component.get('v.piData.selectedPi');
            }

            communityService.executeAction(
                component,
                'getInitData',
                {
                    userMode: communityService.getUserMode(),
                    communityName: communityService.getCurrentCommunityTemplateName(),
                    delegateId: communityService.getDelegateId(),
                    piId: piId,
                    ctpId: ctpId,
                    action: 'Init'
                },
                function (returnValue) {
                    if (!returnValue) communityService.navigateToPage('');

                    let responseData = JSON.parse(returnValue);
                    console.log(responseData);
                    if (communityService.getUserMode() === 'PI') {
                        component.set('v.piData', responseData);
                    } else {
                        if(responseData.enrollmentStatus!==undefined && responseData.enrollmentStatus.length>0 && responseData.enrollmentStatus[0].segment!=undefined){
                            responseData.enrollmentStatus[0].segment = responseData.enrollmentStatus[0].segment.replace('/','/ '); //Added for word break in Dashboard to avoid truncation
                        }
                        component.set('v.hcpData', responseData);
                    }
                    component.set('v.isInitialized', true);
                    //spinner.hide();
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});
