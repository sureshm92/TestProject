public without sharing class ParticipantComorbiditiesTriggerHelper {
    
    public static void updatePERafterInsert (List<Participant_Comorbidities__c> pcListnew) {
        try {
            Set<Id> participantSet = new Set<Id>();
            for (Participant_Comorbidities__c p: pcListnew){
                participantSet.add(p.Participant__c);
            }
            if (!participantSet.isEmpty()) {
                List<Participant_Enrollment__c > perList = [SELECT Comorbidities__c,Name,Participant__c FROM Participant_Enrollment__c WHERE Participant__c IN : participantSet AND Comorbidities__c != 'Yes'];
                
                
                if(!perList.isEmpty()){
                    List<Participant_Enrollment__c > perListToUpdate = new List<Participant_Enrollment__c >();
                    for (Participant_Enrollment__c  per: perList){
                        per.Comorbidities__c = 'Yes';
                        perListToUpdate.add(per);
                    }
                    
                    if(!perListToUpdate.isEmpty()){
                        update perListToUpdate;
                    }
                }
            }
        } catch (Exception  e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
        }
    }
    
    public static void updatePERafterDelete (List<Participant_Comorbidities__c> pcList) {
        try {
            Set<Id> participantSet = new Set<Id>();
            for (Participant_Comorbidities__c p: pcList){
                participantSet.add(p.Participant__c);
            }
            List<Participant_Comorbidities__c> participantComorbiditiesListOld = [SELECT Comorbidities__c, Id,Name,Participant__c FROM Participant_Comorbidities__c WHERE Participant__c IN : participantSet];
            
            Set<Id> participantWithComorbidities = new Set<Id>();
            Set<Id> participantWithoutComorbidities = new Set<Id>();
            for (Participant_Comorbidities__c pc: participantComorbiditiesListOld){
                participantWithComorbidities.add(pc.Participant__c);
            }
            
            for (Id pset: participantSet){
                if(!participantWithComorbidities.contains(pset)){
                    participantWithoutComorbidities.add(pset);
                }
            }
            
            if(!participantWithoutComorbidities.isEmpty()){
                List<Participant_Enrollment__c > perListwithNoComorbidities = [SELECT Comorbidities__c,Name,Participant__c FROM Participant_Enrollment__c WHERE Participant__c IN : participantWithoutComorbidities AND Comorbidities__c != 'No'];
                if(!perListwithNoComorbidities.isEmpty()){
                    List<Participant_Enrollment__c > perListToUpdate = new List<Participant_Enrollment__c >();
                    for (Participant_Enrollment__c  per: perListwithNoComorbidities){
                        per.Comorbidities__c = 'No';
                        perListToUpdate.add(per);
                    }
                    
                    if(!perListToUpdate.isEmpty()){
                        update perListToUpdate;
                    }
                }
            }
        } catch (Exception  e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
        }
    }
}