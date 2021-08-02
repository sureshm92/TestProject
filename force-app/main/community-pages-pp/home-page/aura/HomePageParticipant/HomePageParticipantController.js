/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (returnValue) {
            var ps = JSON.parse(returnValue);
            console.log('ps',ps);
            if (ps.showTerms) {
                communityService.navigateToPage(
                    'trial-terms-and-conditions?id=' +
                        ps.pe.Study_Site__r.Clinical_Trial_Profile__c +
                        '&ret=' +
                        communityService.createRetString()
                );
            } else {
                component.set('v.participantState', ps);
                console.log('authorized'+component.get('v.participantState.pe.isAuthorized__c'))
                if(component.get('v.participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c')){
                    if(component.get('v.participantState.medicalVendors').length !=0 || (component.get('v.participantState.pe.isAuthorized__c') && component.get('v.participantState.pe.Human_Id__c'))){
                        component.set('v.showMedicalCard',true);
                    }
                }
                else{
                    component.set('v.showMedicalCard',false);
                }
                component.set(
                    'v.isDelegateMode',
                    communityService.getCurrentCommunityMode().currentDelegateId
                );

                if (ps.communityName === 'IQVIA Referral Hub')
                    component.set(
                        'v.showTrialSearch',
                        !communityService.getCurrentCommunityMode().currentDelegateId &&
                            !ps.participant.Marketing_Flag__c &&
                            !ps.pe
                    );

                component.find('spinner').hide();
            }
            component.set('v.initialized', true);
        });
    },

    navigateToTrialSearchPage: function (component, event, helper) {
        communityService.navigateToPage('trial-search');
    }
});