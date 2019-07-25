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
            component.set('v.statusSteps', initData.steps);
            component.set('v.enrollment', initData.enrollment);
            component.set('v.enrollment.Screening_ID__c', initData.enrollment.Screening_ID__c || '');
            component.set('v.currentScreeningId', initData.enrollment.Screening_ID__c || '');
            console.log('ENROLLMENT>>>', JSON.parse(JSON.stringify(component.get('v.enrollment'))));
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
            component.set('v.enrollment.Screening_ID__c', enrollment.Screening_ID__c || '');
            component.set('v.currentScreeningId', enrollment.Screening_ID__c || '');
        }, null, function () {
            spinner.hide();
        });
    },

    updateParticipant: function(component, event, helper){
        var participant = component.get('v.participantRecord');
        var peRecord = component.get('v.peRecord');
        console.log('participant:', participant);
        communityService.executeAction(component, 'updateParticipantData', {
            participantJSON: JSON.stringify(participant),
            perJSON : JSON.stringify(peRecord)
        }, function () {
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
            component.set('v.isShowPopup', false);
            //communityService.navigateToPage('referral-profile?id=' +  communityService.getUrlParameter('id'));
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    openPopup: function(component, event, helper){
        component.set('v.isShowPopup', true);
    },

})