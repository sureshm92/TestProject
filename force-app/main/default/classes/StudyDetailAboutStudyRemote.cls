/**
 * Created by Leonid Bartenev
 */

public without sharing class StudyDetailAboutStudyRemote {
    
    /*@AuraEnabled
    public static void changeStudyForHCP(String studySiteId, String hcpeId){
        Savepoint sp = Database.setSavepoint();
        try{
            Study_Site__c studySite = StudySiteService.getStudySiteForHCPById(studySiteId);
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPById(hcpeId);
            new StudyActionsHCP(hcpEnrollment).checkAction(StudyActions.ACT_SEND_SITE_REQUEST);
            hcpEnrollment.Study_Site__c = studySiteId;
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
            if(studySite.Clinical_Trial_Profile__r.Orientation_Required__c) hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_APPROVAL_PENDING;
            upsert hcpEnrollment;
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String selectNoSites(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            return JSON.serialize(setStatusHCP(trialId, 'On Hold (Acceptance)'));
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String setTrialDeclinedForHCP(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            return JSON.serialize(setStatusHCP(trialId, 'Declined (Acceptance)'));
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void setTrialDeclinedForPI(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            setStatusPI(trialId, 'Trial Declined', null);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }*/

    @AuraEnabled
    public static void setTrialAcceptedForPI(Id trialId, String piPaysForReferralActivity, String ssId){
        Savepoint sp = Database.setSavepoint();
        try{
            setStatusPI(trialId, 'Accepted', piPaysForReferralActivity, ssId);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

//    @AuraEnabled
//    public static void setPrimaryContactForStudy(Id trialId, String primaryContactId){
//        if(primaryContactId == '')
//            primaryContactId = null;
//        Savepoint sp = Database.setSavepoint();
//        try{
//            List<Study_Site__c> sites = StudySiteService.getStudySiteForPIByTrialId(trialId);
//            for(Study_Site__c site: sites){
//                site.Primary_Contact__c = primaryContactId;
//            }
//            update sites;
//        }catch (Exception e){
//            Database.rollback(sp);
//            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }

    /*private static Map<Id, HCP_Enrollment__c> setStatusHCP(Id trialId, String status){
        List<HCP_Enrollment__c> enrollments = [
                SELECT Id, Study_Site__c
                FROM HCP_Enrollment__c
                WHERE Study_Site__r.Clinical_Trial_Profile__c =: trialId
                AND HCP_Contact__c =: DelegateService.getContactId(trialId, CommunityService.USER_MODE_HCP)
        ];
        Map<Id, HCP_Enrollment__c> enrollmentsMap = new Map<Id, HCP_Enrollment__c>();
        for(HCP_Enrollment__c enrollment : enrollments){
            enrollment.Status__c = status;
            enrollmentsMap.put(enrollment.Study_Site__c, enrollment);
        }
        update enrollments;
        return enrollmentsMap;
    }*/

    private static void setStatusPI(Id trialId, String status, String piPaysForReferralActivity, String ssId){
        System.debug('ssId>>.'+ssId);
        if(!String.isEmpty(ssId)){
            Study_Site__c studySites = StudySiteService.getStudySiteForHCPById(ssId);
            if(studySites == null) throw new AuraHandledException('Data not found');
            studySites.Override_PI_Referral_Status__c = status;
            if (piPaysForReferralActivity != null) studySites.PI_Pays_for_Referral_Activity__c = piPaysForReferralActivity;
            update studySites;
        }
        else {
            List<Study_Site__c> studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
            if (studySites.size() == null) throw new AuraHandledException('Data not found');
            for (Integer i = 0; i < studySites.size(); i++) {
                if(studySites[i].Override_PI_Referral_Status__c != status && studySites[i].Override_PI_Referral_Status__c != StudySiteService.PI_S_DEACTIVATED_A) {
                    studySites[i].Override_PI_Referral_Status__c = status;
                    if (piPaysForReferralActivity != null) studySites[i].PI_Pays_for_Referral_Activity__c = piPaysForReferralActivity;
               }
             }
            studySites[0].Override_PI_Referral_Status__c = status;
            update studySites;
        }
    }

    @AuraEnabled
    public static List<DocumentWrapper> getDocuments(String role, String ctpId){
        List<Res_study__c> resStudies = [
                SELECT
                        Id,
                        Resource__c,
                        Resource__r.Title__c,
                        Resource__r.Language__c,
                        Visible_To_PI__c,
                        Visible_To_RP__c
                FROM    Res_study__c
                WHERE   Clinical_Trial_Profile__c = :ctpId
        ];
        System.debug(ctpId);
        System.debug(resStudies);
        Set<Id> resourceIds = new Set<Id>();
        Map<String, Res_study__c> resMap = new Map<String, Res_study__c>();
        for(Res_study__c res : resStudies){
            if((role == 'PI' && res.Visible_To_PI__c) || (role == 'HCP' && res.Visible_To_RP__c)) {
                resourceIds.add(res.Resource__c);
                resMap.put(res.Resource__c, res);
            }
        }
        System.debug(resourceIds);
        if(resourceIds.isEmpty())
            return null;
        List<ContentDocumentLink> documents = [
                SELECT  Id,
                        ContentDocumentId,
                        ContentDocument.Title,
                        LinkedEntityId
                FROM    ContentDocumentLink
                WHERE   LinkedEntityId IN :resourceIds
        ];
        List<DocumentWrapper> documentsToShow = new List<DocumentWrapper>();
        System.debug(documents);
        Set<String> uniqueDocumentNames = new Set<String>();
        String userLanguage = UserInfo.getLanguage();
        documentsToShow.addAll(getDefaultLanguageDocuments(documents, uniqueDocumentNames, resMap, userLanguage));
        System.debug(documentsToShow);
        if(userLanguage != 'en_US'){
            documentsToShow.addAll(getDefaultLanguageDocuments(documents, uniqueDocumentNames, resMap, 'en_US'));
        }
        System.debug(documentsToShow);
        return documentsToShow;
    }

    private static List<DocumentWrapper> getDefaultLanguageDocuments(List<ContentDocumentLink> documents, Set<String> uniqueDocumentNames, Map<String, Res_study__c> resMap, String userLanguage){
        List<DocumentWrapper> documentsToShow = new List<DocumentWrapper>();
        for(ContentDocumentLink document : documents){
            if(!uniqueDocumentNames.contains(resMap.get(document.LinkedEntityId).Resource__r.Title__c)) {
                if (document.ContentDocument.Title == userLanguage) {
                    DocumentWrapper doc = new DocumentWrapper(
                            document.LinkedEntityId,
                            resMap.get(document.LinkedEntityId).Resource__r.Title__c,
                            resMap.get(document.LinkedEntityId).Resource__r.Language__c
                    );
                    uniqueDocumentNames.add(resMap.get(document.LinkedEntityId).Resource__r.Title__c);
                    documentsToShow.add(doc);
                }
            }
        }
        return documentsToShow;
    }

    public class DocumentWrapper{
        @AuraEnabled public Id resourceId;
        @AuraEnabled public String title;
        @AuraEnabled public String language;

        public DocumentWrapper(Id resourceId, String title, String language){
            this.resourceId = resourceId;
            this.title = title;
            this.language = language;
        }
    }

}