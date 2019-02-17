/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        if (!communityService.isInitialized()) return;
        if (communityService.getUserMode() === 'Participant') communityService.navigateToPage('');
        component.set('v.userMode', communityService.getUserMode());

        communityService.executeAction(component, 'getInitData', {
            userMode:communityService.getUserMode()
        }, function (returnValue) {
            if(!returnValue) communityService.navigateToPage('');
            var responseData = JSON.parse(returnValue);
            if(communityService.getUserMode() === 'PI'){
                component.set('v.piData', responseData);
            }else{
                component.set('v.hcpData', responseData);
            }
            component.set('v.isInitialized', true);
            spinner.hide();
        });
    }


})