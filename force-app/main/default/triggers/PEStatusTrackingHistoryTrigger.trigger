/**
 * Created by Leonid Bartenev
 */

trigger PEStatusTrackingHistoryTrigger on Participant_Enrollment__c (before insert, before update, after insert, after update) {

    List<Participant_Enrollment_Status_History__c> pesHistoryList = new List<Participant_Enrollment_Status_History__c>();

    for(Participant_Enrollment__c pe : Trigger.new){
        
        //set changed date when insert
        if(Trigger.isBefore && Trigger.isInsert){
            pe.Medical_Record_Review_Completed_Date__c =  Datetime.now();
            if(pe.Participant_Status__c != null && pe.Participant_Status_Last_Changed_Date__c == null)
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
        }
        //reset notes and set change date if not defined
        if(Trigger.isBefore && Trigger.isUpdate){
            if(pe.Participant_Status__c != Trigger.oldMap.get(pe.Id).Participant_Status__c ||
                    pe.Participant_Status_Last_Changed_Date__c != Trigger.oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                    pe.Last_Status_Changed_Notes__c != Trigger.oldMap.get(pe.Id).Last_Status_Changed_Notes__c){
                if(pe.Participant_Status_Last_Changed_Date__c == Trigger.oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c)
                    if(pe.Last_Status_Changed_Notes__c == Trigger.oldMap.get(pe.Id).Last_Status_Changed_Notes__c)
                        pe.Last_Status_Changed_Notes__c = null;
                    pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }

        //create history records when PE created with status or when status or changed date are changed
        if(Trigger.isAfter){
            if ((Trigger.isInsert &&pe.Participant_Status__c != null) ||
                    (Trigger.isUpdate && (pe.Participant_Status__c != Trigger.oldMap.get(pe.Id).Participant_Status__c ||
                                    pe.Participant_Status_Last_Changed_Date__c != Trigger.oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                            pe.Last_Status_Changed_Notes__c != Trigger.oldMap.get(pe.Id).Last_Status_Changed_Notes__c)
                    )){
                pesHistoryList.add(new Participant_Enrollment_Status_History__c(
                        Notes__c = pe.Last_Status_Changed_Notes__c,
                        Date__c = Datetime.now(),
                        ParticipantEnrollment__c = pe.Id,
                        NewStatus__c = pe.Participant_Status__c,
                        Reason__c = pe.Non_Enrollment_Reason__c
                ));
            }
        }
    }
    insert pesHistoryList;
}