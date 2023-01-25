/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {
    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode) {
        try {
            return getTrialDetail(trialId, userMode, null, false);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getTrialDetail(String trialId, String userMode, Boolean isNewPP) {
        try {
            return getTrialDetail(trialId, userMode, null, isNewPP);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId) {
        try {
            return JSON.serialize(TrialFactory.getTrial(userMode, trialId, delegateId));
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId, Boolean isNewPP) {
        try {
            return JSON.serialize(TrialFactory.getTrial(userMode, trialId, delegateId, isNewPP));
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode() {
        return VisitResultSharingService.visitResultSharingByGroupAndMode();
    }

    @AuraEnabled
    public static Boolean gettelevisitData() {
        try {
            List<Televisit_Attendee__c> televisitattendeeList = [Select Televisit__r.Id, Televisit__r.Meeting_URL__c,Televisit__r.Title__c,Televisit__r.Status__c,Televisit__r.Duration__c,Televisit__r.Visit_Date_Time__c from Televisit_Attendee__c where User__c =:UserInfo.getUserId()];
            if(!televisitattendeeList.isEmpty()){
                return true;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
    
    }
