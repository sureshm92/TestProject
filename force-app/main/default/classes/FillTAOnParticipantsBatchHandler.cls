public with sharing class FillTAOnParticipantsBatchHandler implements BatchHandler {
    public void handle(List<SObject> scope) {
        if (!scope.isEmpty()) {
            List<Participant__c> participants = (List<Participant__c>) scope;
            List<Therapeutic_Area_Patient__c> assignmentsToCreate = new List<Therapeutic_Area_Patient__c>();
            TherapeuticAreaPatientService service = (TherapeuticAreaPatientService) ClassFactory.newInstance(
                TherapeuticAreaPatientService.class
            );

            for (Participant__c singleParticipant : participants) {
                if (
                    singleParticipant.Therapeutic_Area_Patients__r.isEmpty() &&
                    !singleParticipant.Participant_Profile__r.isEmpty()
                ) {
                    Participant_Enrollment__c singleEnrollment = singleParticipant.Participant_Profile__r[0];
                    if (
                        singleEnrollment.Study_Site__c != null &&
                        singleEnrollment.Study_Site__r.Clinical_Trial_Profile__c != null &&
                        !PEStatusState.PE_STATUS_GROUP_FAILED.contains(
                            singleEnrollment.Participant_Status__c
                        )
                    ) {
                        Clinical_Trial_Profile__c singleCTP = singleEnrollment.Study_Site__r.Clinical_Trial_Profile__r;
                        if (singleCTP.Therapeutic_Area__c != null) {
                            assignmentsToCreate.add(
                                service.getRelatedToStudyTherapeuticAreaPatient(
                                    singleParticipant.Id,
                                    singleCTP.Therapeutic_Area__c
                                )
                            );
                        }
                    }
                }
            }
            insert new List<Therapeutic_Area_Patient__c>(assignmentsToCreate);
        }
    }

    public void processResult() {
    }

    public void processScopeResult() {
    }
}
