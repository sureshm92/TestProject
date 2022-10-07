/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            if (communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
            let spinner = component.find('mainSpinner');
            spinner.show();
            let recId = communityService.getUrlParameter('id');
            let hcpeId = communityService.getUrlParameter('hcpeid');
            let delegateId = communityService.getDelegateId();

            if (recId) {
                component.set('v.trialId', recId);
                component.set('v.hcpeId', hcpeId);
                communityService.executeAction(
                    component,
                    'getInitData',
                    {
                        trialId: recId,
                        hcpeId: hcpeId,
                        delegateId: delegateId
                    },
                    function (returnValue) {
                        let initData = JSON.parse(returnValue);
                        let searchData = {
                            participantId: ''
                        };
                        component.set('v.searchData', searchData);
                        component.set('v.hcpEnrollment', initData.hcpEnrollment);
                        component.set('v.hcpContact', initData.hcpContact);
                        component.set('v.hcpEnrollmentParticipantName', initData.hcpEnrollmentParticipantName);
                        component.set('v.hcpContactParticipant', initData.hcpContactParticipant);
                        if(initData.hcpContactParticipant!=undefined && initData.hcpContactParticipant !=null){
                            let partName;
                            if(initData.hcpContactParticipant.Salutation__c!=undefined){
                                component.set('v.hcpContactParticipantSal', initData.hcpContactParticipant.Salutation__c);
                            }
                            if(initData.hcpContactParticipant.First_Name__c!=undefined){
                                partName = partName==undefined?initData.hcpContactParticipant.First_Name__c : partName + ' ' + initData.hcpContactParticipant.First_Name__c;
                            }
                            if(initData.hcpContactParticipant.Middle_Name__c!=undefined){
                                partName = partName==undefined?initData.hcpContactParticipant.Middle_Name__c : partName + ' ' + initData.hcpContactParticipant.Middle_Name__c;
                            }
                            if(initData.hcpContactParticipant.Last_Name__c!=undefined){
                                partName = partName==undefined?initData.hcpContactParticipant.Last_Name__c : partName + ' ' + initData.hcpContactParticipant.Last_Name__c;
                            }
                            if(initData.hcpContactParticipant.Suffix__c!=undefined){
                                partName = partName==undefined?initData.hcpContactParticipant.Suffix__c : partName + ' ' + initData.hcpContactParticipant.Suffix__c;
                            }
                            component.set('v.hcpContactParticipantName', partName);
                        }
                        component.set('v.accessUserLevel', initData.delegateAccessLevel);
                        component.set('v.trial', initData.trial);
                        component.set('v.preSurvey', initData.preSurvey);
                        component.set('v.actions', initData.actions);
                    },
                    null,
                    function () {
                        spinner.hide();
                    }
                );
            }
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doGoHome: function () {
        //communityService.navigateToPage('');
        communityService.navigateToPage('my-patients');
    },

    doStartMRR: function (component) {
        communityService.navigateToPage('medical-record-review?id=' + component.get('v.trialId'));
    },

    doReferPatient: function (component) {
        communityService.navigateToPage(
            'referring?id=' +
                component.get('v.trialId') +
                '&peid=' +
                component.get('v.searchResult').pe.Id  
        ); 
        /**communityService.navigateToPage(
            'referring?id=' +
                component.get('v.trialId') +
                '&peid=' +
                component.get('v.searchResult').pe.Id  +
                '&patientVeiwRedirection=true'  +
                '&mystudies=true'
        );**/
    },

    doClearForm: function (component) {
        component.set('v.searchResult', undefined);
        component.set('v.searchData', {
            participantId: ''
        });
        component.set('v.mrrResult', 'Pending');
    },

    doMRRResultChanged: function () {
        window.scrollTo(0, 0);
    }
});