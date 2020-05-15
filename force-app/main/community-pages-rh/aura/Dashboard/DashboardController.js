/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            spinner.show();
            if (communityService.getUserMode() === 'Participant') communityService.navigateToPage('');
            component.set('v.userMode', communityService.getUserMode());

            let ctpId = null;
            let piId = null;
            if (component.get('v.piData')) {
                if (component.get('v.piData.selectedCTP')) ctpId = component.get('v.piData.selectedCTP');
                if (component.get('v.piData.selectedPi')) piId = component.get('v.piData.selectedPi');
            }

            communityService.executeAction(component, 'getInitData', {
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
                piId: piId,
                ctpId: ctpId,
                action: 'Init'
            }, function (returnValue) {
                if (!returnValue) communityService.navigateToPage('');
                let responseData = JSON.parse(returnValue);
                if (communityService.getUserMode() === 'PI') {
                    component.set('v.piData', responseData);
                } else {
                    component.set('v.hcpData', responseData);
                }
                component.set('v.isInitialized', true);
                spinner.hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});