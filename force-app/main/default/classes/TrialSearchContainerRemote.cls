/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchContainerRemote {

    @AuraEnabled
    public static TrialSearchContainer getSearchCTPs() {
        TrialSearchContainer trialSearchContainer = new TrialSearchContainer();
        List<Clinical_Trial_Profile__c> ctps = [
                SELECT
                        Therapeutic_Area__c,
                        Therapeutic_Area__r.Name,
                        Study_Code_Name__c,
                        Official_Title__c,
                        Enrollment_Start_Date__c,
                        Override_Recruitment_Status__c,
                        Recruitment_Status__c
                FROM Clinical_Trial_Profile__c
                ORDER BY Study_Code_Name__c
        ];

        Set<Id> taIds = new Set<Id>();

        for (Clinical_Trial_Profile__c ctp : ctps) {
            if (ctp.Therapeutic_Area__c != null) {
                taIds.add(ctp.Therapeutic_Area__c);
            }
        }

        Map<Id, Therapeutic_Area__c> therapeuticAreaByParent;

        if (!taIds.isEmpty()) {
//            List<Therapeutic_Area__c> therapeuticAreas = [
//                    SELECT Id, Therapeutic_Area__c, Name FROM Therapeutic_Area__c WHERE Therapeutic_Area__c IN :(taIds) AND RecordType.DeveloperName = :TherapeuticAreaService.COI_RT_NAME
//            ];
//            System.debug('therapeuticAreas ===> ' + therapeuticAreas);

            therapeuticAreaByParent = new Map<Id, Therapeutic_Area__c>([
                    SELECT Id,
                            Name, (SELECT Name, Therapeutic_Area__c FROM Therapeutic_Areas__r WHERE RecordType.DeveloperName = :TherapeuticAreaService.COI_RT_NAME)
                    FROM Therapeutic_Area__c
                    WHERE Id IN :(taIds)
            ]);
        }
        List<TrialTDO> tdos = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            TrialTDO tdo =  new TrialTDO();
            tdo.ctp = ctp;
            List<Therapeutic_Area__c> tasTemp = therapeuticAreaByParent.get(ctp.Therapeutic_Area__c).Therapeutic_Areas__r;
            if (tasTemp != null && !tasTemp.isEmpty()) {
                tdo.cois = tasTemp;
            }
            tdos.add(tdo);
        }
        trialSearchContainer.TrialTDOs = tdos;
        System.debug(' ===> ' + tdos);

        return trialSearchContainer;
    }

    public class TrialSearchContainer {
        @AuraEnabled
        public List<TrialTDO> TrialTDOs;

    }

    public class TrialTDO {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public List<Therapeutic_Area__c> cois;
    }
}