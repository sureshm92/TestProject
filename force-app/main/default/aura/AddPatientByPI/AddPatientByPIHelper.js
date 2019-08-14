/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component) {
        var ss = component.get('v.ss');
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: ss.Principal_Investigator__r.Account.BillingCountryCode,
            Mailing_State_Code__c: ss.Principal_Investigator__r.Account.BillingStateCode
        });
        component.set('v.pe', {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: ss.Id
        });
        component.find('editForm').set('v.handleChangesEnabled', true);
    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var helper = this;
        if(pe.Participant_Status__c === 'Enrollment Success') {
            component.find('actionApprove').execute(function () {
                helper.saveParticipant(component, pe, callback);
            }, function () {
                component.find('spinner').hide();
                communityService.showWarningToast(null, $A.get('$Label.c.Toast_ICF'));
            });
        } else {
            helper.saveParticipant(component, pe, callback);
        }
    },

    saveParticipant : function (component, pe, callback) {
        var helper = this;
        var participant = component.get('v.participant');
        communityService.executeAction(component, 'createParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function (createdPE) {
            createdPE.Participant_Status__c = pe.Participant_Status__c;
            helper.updatePE(component, createdPE, function () {
                communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                callback();
            })
        }, function () {
            component.find('spinner').hide();
        });
    },

    updatePE: function (component, pe, callback) {
        communityService.executeAction(component, 'updatePE', {
            peJSON: JSON.stringify(pe)
        }, function () {
            callback();
        }, null, function () {
            component.find('spinner').hide();
        });
    }
})