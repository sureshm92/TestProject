/**
 * Created by user on 11.04.2019.
 */

public with sharing class ParticipantVisitsRemote {

    @AuraEnabled
    public static String getVisitsPreview() {
        try{
            return JSON.serialize(VisitService.getInstance().getPreviewVisits());
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getParticipantVisits() {
        try{
            return JSON.serialize(VisitService.getInstance().getAllVisits());
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}