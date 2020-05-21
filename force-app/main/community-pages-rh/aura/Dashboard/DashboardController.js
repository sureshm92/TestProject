/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        //component.set('v.isInitialized', false);
        var spinner = component.find('mainSpinner');
        spinner.show();
        if (!communityService.isInitialized()) return;
        if (communityService.getUserMode() === 'Participant') communityService.navigateToPage('');
        component.set('v.userMode', communityService.getUserMode());
        var piId = null;
        if(component.get('v.piData') && component.get('v.piData.selectedPi')){
            piId = component.get('v.piData.selectedPi');
        }
        communityService.executeAction(component, 'getInitData', {
            userMode:communityService.getUserMode(),
            delegateId:communityService.getDelegateId(),
            piId: piId
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