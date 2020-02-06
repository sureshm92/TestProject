/**
 * Created by Nikita Abrazhevitch on 05-Sep-19.
 */

public without sharing class ParticipantInformationRemote {

    @AuraEnabled
    public static AddPatientByPIRemote.FormData getInitData() {
        try {
            AddPatientByPIRemote.FormData formData = AddPatientByPIRemote.getInitData(null);
            return formData;
        } catch (Exception e) {
            return (AddPatientByPIRemote.FormData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSteps(String peId, String userMode, String delegateId) {
        try {
            String steps = ReferralProfileRemote.getReferralProfileDetail(peId, userMode, delegateId);
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPrintInformation(String peId, String userMode, String delegateId) {
        try {
            String steps = ReferralProfileRemote.getReferralProfileDetail(peId, userMode, delegateId);
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON) {
        AddPatientByPIRemote.updatePatientInfo(participantJSON, peJSON);
    }

    @AuraEnabled
    public static String updatePatientStatus(String stepWrapperJSON, String peId){
        try {
            String steps = ReferralProfileRemote.updateParticipantStatus(stepWrapperJSON, peId);
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

}