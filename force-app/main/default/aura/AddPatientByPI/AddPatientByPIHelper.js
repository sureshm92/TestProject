/**
 * Created by Leonid Bartenev
 */
({
    initData: function (component) {
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US'
        });
        component.set('v.pe', {
            sobjectType: 'Participant_Enrollment__c',
            Study_Site__c: component.get('v.ss.Id'),
        });
    },

    initDataEdit: function (component) {
        component.set('v.participant', {
            sobjectType: 'Participant__c',
            Mailing_Country_Code__c: 'US'
        });
        
        var pId = communityService.getUrlParameter('id');
        console.log('pId', pId);
        communityService.executeAction(component, 'getParticipantRecord', {
            participantEnrollmentId: pId
        }, function (formData) {
            console.log('formData', formData);
            component.set('v.participant', formData.participantRecord); 
            component.set('v.pe', formData.peRecord);
        }, null, function () {
            component.find('spinner').hide();
        });

    },

    createParticipant: function (component, callback) {
        component.find('spinner').show();
        var pe = component.get('v.pe');
        var helper = this;
       
        if(pe.Participant_Status__c === 'Enrollment Success') {
            component.find('actionApprove').execute(function () {
                pe.Informed_Consent__c = true;
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
        var doAdditionalCallout = false;
        if(pe.Participant_Status__c === 'Enrollment Success'){
            pe.Participant_Status__c = 'Screening In Progress';
            doAdditionalCallout = true;
        }else if(pe.Participant_Status__c === 'Temporary Status'){
             pe.Participant_Status__c = 'Enrollment Success';
             doAdditionalCallout = false;
        }
        var participant = component.get('v.participant');
        console.log('participant', participant);
        console.log('pe', pe);
        communityService.executeAction(component, 'saveParticipant', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function (peId) {
            console.log('peId', peId);
            if(doAdditionalCallout){
                pe.Participant_Status__c = 'Temporary Status';
                pe.Id = peId;
                helper.saveParticipant(component, pe, callback);
            }
            else{
                communityService.showSuccessToast('', $A.get('$Label.c.PG_AP_Success_Message'));
                callback();
            }
        }, null, function () {
            component.find('spinner').hide();
        });
    }
})