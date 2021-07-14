public without sharing class RPRecordReviewLogController {

    @AuraEnabled(cacheable=true)
    public static peDataRpWrapper getRecordsDetails() {
        try {
            peDataRpWrapper peData = new peDataRpWrapper();
            peData.participantStatus = new List<LabelValueItem>();
            peData.participantStatus.add(new LabelValueItem(ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING,
                                            ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING));
            return peData;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    public class peDataRpWrapper {
         @AuraEnabled public List<LabelValueItem> participantStatus { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            LIMIT 10
        ];
    }


}