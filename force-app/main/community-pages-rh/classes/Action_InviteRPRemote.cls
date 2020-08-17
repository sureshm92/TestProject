/**
 * Created by Kryvolap on 13.08.2019.
 */

public without sharing class Action_InviteRPRemote {

    @AuraEnabled
    public static String getInviteDetail() {
        InviteDetail inviteDetail = new InviteDetail();
        inviteDetail.studySitesForInvitation = new List<SiteWrapper>();
        inviteDetail.PIForInvetation = getPIForInvetation();
        /*try {
            List<Study_Site__c> studySitesNotDelegate = StudySiteService.getStudySitesForPI();
            inviteDetail.studySitesForInvitation = new List<SiteWrapper>();
            if (studySitesNotDelegate != null && !studySitesNotDelegate.isEmpty()) {
                Set<Id> studyIds = new Set<Id>();
                for (Study_Site__c site : studySitesNotDelegate) {
                    if (!studyIds.contains(site.Id) && StudySiteService.STATUS_GROUP_ACCEPTED.contains(site.Override_PI_Referral_Status__c)) {
                        SiteWrapper sw = new SiteWrapper(site.Clinical_Trial_Profile__r.Study_Code_Name__c, site.Id, site.Clinical_Trial_Profile__r.Protocol_ID__c, site.Name);
                        inviteDetail.studySitesForInvitation.add(sw);
                        studyIds.add(site.Id);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }*/
        return JSON.serialize(inviteDetail);
    }

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDuplicate(String email) {
        return ReferHealthcareProviderRemote.checkDuplicate(null, email, null, null, null);
    }

    @AuraEnabled
    public static String inviteExistingHCP(String hcpContactId, List<String> piIds) {
        try {
            ReferHealthcareProviderRemote.createHCPinPlatform(CommunityService.getUserContact().Id, hcpContactId, piIds);
            return Label.TST_Request_to_invite_a_referring_provider;
        } catch (Exception e) {
            return Label.RP_Is_Already_Invited;
        }
    }

    @AuraEnabled
    public static void inviteNewHCP(String firstName, String lastName, String phone, String email, String studySiteId, String protocolId, List<String> piIds){
        try{
            List<Group> invitationQueues = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :CommunityService.INVITATION_QUEUE];
            AssignmentRule ar = new AssignmentRule();
            ar = [
                    SELECT 	id
                    FROM 	AssignmentRule
                    WHERE 	SobjectType = 'Lead' AND
                    Active = true AND
                    Name = 'SPNL Assignment Rule'
                    LIMIT 1
            ];

            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;

            Boolean isConvertNeed = false;

            Lead l = new Lead();
            l.FirstName = firstName;
            l.LastName = lastName;
            l.Phone = phone;
            if (!String.isBlank(email)) {
                l.Email = email;
                isConvertNeed = true;
            }
            l.Company = lastName +' temporary account';
            l.Protocol_Number__c = protocolId;
            l.Language__c = UserInfo.getLanguage();
            if (String.isNotBlank(studySiteId)) {
                l.Study_Site__c = studySiteId;
            }
            l.Status = 'New';
            Contact piContact = CommunityService.getUserContact();
            if (piContact != null) {
                l.Invited_by_PI__c = piContact.Id;
            }
            if (invitationQueues.size() > 0) {
                l.OwnerId = invitationQueues[0].Id;
            }
            if (!isConvertNeed) {
                l.setOptions(dmlOpts);
                insert l;
            } else {
               //ReferHealthcareProviderRemote.createHCPinPlatform(null, firstName, lastName, email, phone, piContact);
                ReferHealthcareProviderRemote.createHCPinPlatform(null, firstName, lastName, email, phone, piContact, piIds);
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static List<PIOptionWrapper> getPIForInvetation(){
        List<PIOptionWrapper> result = new List<PIOptionWrapper>();
        Map<Id,String> piOtions = new Map<Id,String>();
        for (Site_Staff__c sstaff : [
                SELECT Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name
                FROM Site_Staff__c
                WHERE Site_Contact__c = :CommunityService.getUserContact().Id AND Delegate_Level__c = 'Level 1'
        ]){
            piOtions.put(sstaff.Study_Site__r.Principal_Investigator__c, sstaff.Study_Site__r.Principal_Investigator__r.Name);
            //inviteDetail.PIForInvetation.add(new PIOptionWrapper(sstaff.Study_Site__r.Principal_Investigator__c, sstaff.Study_Site__r.Principal_Investigator__r.Name));
        }
        for(Id i : piOtions.keySet()){
            result.add(new PIOptionWrapper(piOtions.get(i), i));
        }
        return result;
    }

    public static List<PIOptionWrapper> getPIForInvetation(String communityTemplateName){
        List<PIOptionWrapper> result = new List<PIOptionWrapper>();
        Map<Id,String> piOtions = new Map<Id,String>();
        for (Site_Staff__c sstaff : [
                SELECT Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name
                FROM Site_Staff__c
                WHERE Site_Contact__c = :CommunityService.getUserContact().Id AND Delegate_Level__c = 'Level 1'
                AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c =: communityTemplateName
        ]){
            piOtions.put(sstaff.Study_Site__r.Principal_Investigator__c, sstaff.Study_Site__r.Principal_Investigator__r.Name);
            //inviteDetail.PIForInvetation.add(new PIOptionWrapper(sstaff.Study_Site__r.Principal_Investigator__c, sstaff.Study_Site__r.Principal_Investigator__r.Name));
        }
        for(Id i : piOtions.keySet()){
            result.add(new PIOptionWrapper(piOtions.get(i), i));
        }
        return result;
    }

    public class InviteDetail {
        public  List<SiteWrapper> studySitesForInvitation;
        @AuraEnabled public List<PIOptionWrapper> PIForInvetation;
    }
    public class SiteWrapper{
        public String StudyName;
        public String Id;
        public Boolean selected;
        public String protocolId;
        public String studySiteName;
        public SiteWrapper(String StudyName, String Id){
            this.StudyName = StudyName;
            this.Id = Id;
            this.selected = false;
        }
        public SiteWrapper(String StudyName, String Id, String protocolId, String studySiteName){
            this.StudyName = StudyName;
            this.studySiteName = studySiteName;
            this.Id = Id;
            this.selected = false;
            this.protocolId = protocolId;
        }
    }

    public class PIOptionWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public Id value;

        public PIOptionWrapper(String label,Id value){
            this.label = label;
            this.value = value;
        }
    }
}