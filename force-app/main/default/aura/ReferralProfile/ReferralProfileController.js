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
        component.set('v.multiMode', communityService.getCommunityTypes().length > 1);
        var peId = communityService.getUrlParameter("id");
        if(!peId) {
            communityService.navigateToPage('');
            return;
        }

        component.set('v.peId', peId);

        communityService.executeAction(component, 'getReferralProfileDetail',{
            peId: peId,
            userMode: communityService.getUserMode()
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            debugger;
            component.set('v.statusSteps', initData.steps);
            component.set('v.enrollment', initData.enrollment);
            component.set('v.enrollment.Screening_ID__c', initData.enrollment.Screening_ID__c || '');
            component.set('v.currentScreeningId', initData.enrollment.Screening_ID__c || '');
            //set sticky bar position in browser window
            if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
            component.set('v.isInitialized', true);
        }, null, function () {
            spinner.hide();
        });
    },
    saveScreeningId: function (component, event, hepler) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        communityService.executeAction(component, 'savePEScreeningId',{
            peId: component.get('v.enrollment.Id'),
            newScreeningId: component.get('v.enrollment.Screening_ID__c')
        }, function (returnValue) {
            var enrollment = JSON.parse(returnValue);
            debugger;
            component.set('v.enrollment.Screening_ID__c', enrollment.Screening_ID__c || '');
            component.set('v.currentScreeningId', enrollment.Screening_ID__c || '');
        }, null, function () {
            spinner.hide();
        });
    }

})