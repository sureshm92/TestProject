/**
 * Created by Leonid Bartenev
 */
({

    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        var spinner = component.find('mainSpinner');
        spinner.show();
        if(communityService.getUserMode() !== 'PI'){
            communityService.navigateToPage('');
            return;
        }
        component.set('v.multiMode', communityService.getAllUserModes().length > 1);
        var peId = communityService.getUrlParameter('id');
        if(!peId) {
            communityService.navigateToPage('');
            return;
        }
        communityService.executeAction(component, 'getReferralProfileDetail',{
            peId: peId,
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId(),
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.statusSteps', initData.steps);
            component.set('v.pe', initData.enrollment);
            //set sticky bar position in browser window
            if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
            component.set('v.isInitialized', true);
        }, null, function () {
            spinner.hide();
        });
    },

    doEditPatientInfo: function(component, event, helper){
        var pe = component.get('v.pe');
        component.find('updatePatientInfoAction').execute(pe, false, function (pe) {
            component.set('v.pe', pe);
        });
    }

})