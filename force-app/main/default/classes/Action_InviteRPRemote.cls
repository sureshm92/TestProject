/**
 * Created by Kryvolap on 13.08.2019.
 */

public without sharing class Action_InviteRPRemote {

    @AuraEnabled
    public static String getInviteDetail() {
        InviteDetail inviteDetail = new InviteDetail();
        try {
            List<Study_Site__c> studySitesNotDelegate = StudySiteService.getStudySitesForPI();
            inviteDetail.studySitesForInvitation = new List<SiteWrapper>();
            if (studySitesNotDelegate != null && !studySitesNotDelegate.isEmpty()) {
                Set<Id> studyIds = new Set<Id>();
                for (Study_Site__c site : studySitesNotDelegate) {
                    if (!studyIds.contains(site.Clinical_Trial_Profile__c) && StudySiteService.STATUS_GROUP_ACCEPTED.contains(site.Override_PI_Referral_Status__c)) {
                        SiteWrapper sw = new SiteWrapper(site.Clinical_Trial_Profile__r.Study_Code_Name__c, site.Id, site.Clinical_Trial_Profile__r.Protocol_ID__c);
                        inviteDetail.studySitesForInvitation.add(sw);
                        studyIds.add(site.Clinical_Trial_Profile__c);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(inviteDetail);
    }

    @AuraEnabled
    public static void inviteHCP(String firstName, String lastName, String clinicName, String phone, String email, String studySiteId, String protocolId){
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
            l.Company = clinicName;
            l.Protocol_Number__c = protocolId;
            l.Language__c = UserInfo.getLanguage();
            if(studySiteId!= null && studySiteId != '')
                l.Study_Site__c = studySiteId;
            l.Status = 'New';
            l.Invited_by_PI__c = CommunityService.getUserContact().Id;
            if(invitationQueues.size() > 0){
                l.OwnerId = invitationQueues[0].Id;
            }
            if (!isConvertNeed || String.isBlank(studySiteId)) {
                l.setOptions(dmlOpts);
                insert l;
            } else if (!String.isBlank(studySiteId)) {
                Study_Site__c studySite = [SELECT Id, Site__c, Site__r.BillingCountry FROM Study_Site__c WHERE Id = :studySiteId];
                List<Contact> cntList = [SELECT Id, userCommunityMode__c, userCommunytyType__c
                                         FROM Contact
                                         WHERE Email = :email OR
                                               Email = :email.toLowerCase() OR
                                               Phone = :phone LIMIT 1];
                if (cntList.isEmpty()) {
                    cntList.add(new Contact(FirstName = firstName,
                            LastName = lastName,
                            Phone = phone,
                            Email = email,
                            AccountId = studySite.Site__c,
                            Language__c = UserInfo.getLanguage(),
                            MailingCountry = studySite.Site__r.BillingCountry));
                    insert cntList;
                }

                List<User> usrs = CommunityService.getCommunityUsersByContactIds(new Set<Id> { cntList[0].Id });

                if (usrs.isEmpty()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id> { cntList[0].Id });
                }
                if (cntList[0].userCommunytyType__c == null) {
                    cntList[0].userCommunytyType__c = CommunityService.USER_MODE_HCP;
                } else if (!cntList[0].userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) {
                    cntList[0].userCommunytyType__c = cntList[0].userCommunytyType__c + ';' + CommunityService.USER_MODE_HCP;
                }
                if (cntList[0].userCommunityMode__c != CommunityService.USER_MODE_HCP) {
                    cntList[0].userCommunityMode__c = CommunityService.USER_MODE_HCP;
                }

                HCP_Enrollment__c hcpe = new HCP_Enrollment__c(
                        HCP_Contact__c = cntList[0].Id,
                        Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT,
                        Study_Site__c = studySiteId
                );
                insert hcpe;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class InviteDetail {
        public  List<SiteWrapper> studySitesForInvitation;
    }
    public class SiteWrapper{
        public String StudyName;
        public String Id;
        public Boolean selected;
        public String protocolId;
        public SiteWrapper(String StudyName, String Id){
            this.StudyName = StudyName;
            this.Id = Id;
            this.selected = false;
        }
        public SiteWrapper(String StudyName, String Id, String protocolId){
            this.StudyName = StudyName;
            this.Id = Id;
            this.selected = false;
            this.protocolId = protocolId;
        }
    }
}