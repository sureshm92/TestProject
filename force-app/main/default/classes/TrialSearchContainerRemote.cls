/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchContainerRemote {

    public static final String ACTIVELY_ENROLLING = 'Actively Enrolling';

    public static final List<String> ORS_STATUS_ENROLLING = new List<String>{
            'Actively Enrolling',
            'On Hold'
    };

    public static final List<String> CTMS_RECRUITMENT_ENROLLING = new List<String>{
            'Enrolling',
            'Open to Enrollment',
            'Planning',
            'In Development'
    };

    @AuraEnabled
    public static TrialSearchContainer getSearchCTPs() {
        TrialSearchContainer trialSearchContainer = new TrialSearchContainer();
        String query = 'SELECT ' +
                'Therapeutic_Area__c, ' +
                'Therapeutic_Area__r.Name, ' +
                'Study_Code_Name__c, ' +
                'Official_Title__c, ' +
                'Enrollment_Start_Date__c, ' +
                'Override_Recruitment_Status__c, ' +
                'Recruitment_Status__c ' +
                'FROM Clinical_Trial_Profile__c ' +
                'WHERE Override_Recruitment_Status__c IN ' + '(\'' + String.join(ORS_STATUS_ENROLLING, '\',\'') + '\') ' +
                'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_RECRUITMENT_ENROLLING, '\',\'') + '\') ' +
                'ORDER BY Enrollment_Start_Date__c';
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));

        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(query, true);

        Set<Id> taIds = new Set<Id>();

        for (Clinical_Trial_Profile__c ctp : ctps) {
            if (ctp.Therapeutic_Area__c != null) {
                taIds.add(ctp.Therapeutic_Area__c);
            }
        }

        Map<Id, Therapeutic_Area__c> therapeuticAreaByParent;

        if (!taIds.isEmpty()) {
            therapeuticAreaByParent = new Map<Id, Therapeutic_Area__c>([
                    SELECT Id,
                            Name, (SELECT Name, Therapeutic_Area__c FROM Therapeutic_Areas__r WHERE RecordType.DeveloperName = :TherapeuticAreaService.COI_RT_NAME)
                    FROM Therapeutic_Area__c
                    WHERE Id IN :(taIds)
            ]);
        }
        List<TrialTDO> tdos = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            TrialTDO tdo = new TrialTDO();
            tdo.ctp = ctp;
            if (String.isNotBlank(ctp.Override_Recruitment_Status__c)) {
                tdo.isGreenLine = ctp.Override_Recruitment_Status__c == ACTIVELY_ENROLLING;
            } else if (String.isNotBlank(ctp.Recruitment_Status__c)) {
                tdo.isGreenLine = ctp.Recruitment_Status__c == 'Enrolling' || ctp.Recruitment_Status__c == 'Open to Enrollment';
            }
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
        @AuraEnabled
        public Boolean isGreenLine;
    }
}