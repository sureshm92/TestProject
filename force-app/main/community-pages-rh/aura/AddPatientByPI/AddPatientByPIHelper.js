/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component) {
        var ss = component.get('v.ss');
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US',
            Mailing_State_Code__c: ss.Principal_Investigator__r.Account.BillingStateCode
        });
        let formData = component.get('v.formData');
        let pe = {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: ss.Id
        }
        if(formData.visitPlansLVList && formData.visitPlansLVList.length === 1){
            pe.Visit_Plan__c = formData.visitPlansLVList[0].value;
        }
        component.set('v.pe', pe);
    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var participant = component.get('v.participant');
        var userLanguage = component.get('v.userLanguage');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe),
            userLanguage: userLanguage,
            ssId: (ssId ? ssId : component.get('v.ss').Id),
            createUser: component.get('v.createUsers')
        }, function (createdPE) {
            communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
            callback();
        }, null, function () {
            component.find('spinner').hide();
        });
    }
})