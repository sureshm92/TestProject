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
        var ctpId = null;
        if(component.get('v.piData') && component.get('v.piData.selectedPi')){
            piId = component.get('v.piData.selectedPi');
        }

        if(component.get('v.piData') && component.get('v.piData.selectedCTP')){
            ctpId = component.get('v.piData.selectedCTP');
        }
        communityService.executeAction(component, 'getInitData', {
            userMode:communityService.getUserMode(),
            delegateId:communityService.getDelegateId(),
            piId: piId,
            ctpId: ctpId,
            action: 'Init'
        }, function (returnValue) {
            if(!returnValue) communityService.navigateToPage('');
            var responseData = JSON.parse(returnValue);
            console.log(responseData);
            if(communityService.getUserMode() === 'PI'){
                component.set('v.piData', responseData);
                var pida = component.get('v.piData');
                console.log('pida' + pida);
            }else{
                component.set('v.hcpData', responseData);
            }
            component.set('v.isInitialized', true);
            spinner.hide();
        });
    }


})