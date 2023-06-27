@isTest
public class Test_CommunityService {
    
    @TestSetup
    public static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
	@IsTest
    static void test_LanguageSwitcher() {
        Set<Id> contactId = new Set<Id>();
        List<User> usrLst = [select Id,contactId from user where contactId!=null LIMIT 5];
        User piUsr = [select Id,Contact.userCommunytyType__c,contactId  from user where contactId!=null  and Contact.userCommunytyType__c='PI'];
        Test.startTest();
        System.runAs(piUsr) {
            CommunityService.getInstance();
            CommunityService.getUserId();
            Contact con = CommunityService.getUserContact();
            //CommunityService.getContactsByUserContactIds();
            CommunityService.getCommunityProfile();
            CommunityService.getCommunityURLFromTemplateName('Default');
            CommunityService.getCommunityURLFromTemplateName('GSK');
            CommunityService.isUserModeValid('PI');
                CommunityService.isNewSession();
            //CommunityService.getAvailableUserNameBulk('test2email.com');
            //getMaxLength
            
            for(User usr : usrLst){
                contactId.add(usr.contactId);
            }
            CommunityService.getContactsByUserContactIds(contactId);
            CommunityService.getCommunityUsersByContactIds(contactId);
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .getUserAccessLevel(piUsr.contactId);
        }
        List<Id> conatctIdLst = new List<Id>();
        contactId.clear();
        for(User usr : usrLst){
            conatctIdLst.add(usr.contactId);
            contactId.add(usr.contactId);
        }
        CommunityService.deactivateUsers(conatctIdLst);
        CommunityService.ActivateUsers(contactId);
        CommunityService.getContacts(contactId,true);
        CommunityService.setUserToCommunity(usrLst[0].contactId);
        CommunityService.getContactUserMode(usrLst[0].contactId);
        //CommunityService.getCommunityId('GSK');
        CommunityService.getCommunityIdsMap();
        List<String> fields = new List<String>();
        fields.add('Id');
        CommunityService.getContactsWithFields(contactId,fields);
        CommunityService.isUserInCommunity(usrLst[0].contactId);
        Contact userContact = new Contact();
        CommunityService.getMaxLength(userContact,fields);
        Test.stopTest();
    }
    
    @IsTest
    static void test_createUser1() {
        Account acc = [select Id from account limit 1];
        List<Contact> conLst = new List<Contact>();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            AccountId = acc.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT
        );
        conLst.add(delegate);
        Contact delegate2 = new Contact(
            FirstName = 'Patient2',
            LastName = 'Delegate2',
            Email = 'Delegate2@somemail.com',
            AccountId = acc.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT
        );
        conLst.add(delegate2);
        insert conLst;
        
        Participant_Enrollment__c pe =[select Id,Participant_Contact__c,PI_Contact__c from Participant_Enrollment__c WHERE Screening_ID__c=:'PESCR2' limit 1];
        Map<Id, Id> createUsersMap = new Map<Id, Id>();
        createUsersMap.put(pe.Participant_Contact__c,pe.PI_Contact__c);
        CommunityService.createUserBulk(conLst[0],null,null,null);
        ((CommunityService) ClassFactory.newInstance(CommunityService.class))
               .createParticipantUsers(createUsersMap);
        CommunityService.createUserBulk(conLst[0],null,null,null);
        ((CommunityService) ClassFactory.newInstance(CommunityService.class))
               .createCCPortalUsers(new Set<Id>{conLst[1].Id});
    }
    
    @IsTest
    static void test_createUser2() {
        Participant_Enrollment__c pe =[select Id,Participant_Contact__c,PI_Contact__c from Participant_Enrollment__c limit 1];
        Map<Id, Id> createUsersMap = new Map<Id, Id>();
        try{
            createUsersMap.put(pe.Participant_Contact__c,pe.PI_Contact__c);
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                   .createParticipantUsersBulk(createUsersMap);
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            pe =[select Id,Participant_Contact__c,PI_Contact__c,Participant__r.Contact__c,HCP__r.HCP_Contact__c from Participant_Enrollment__c where Participant__c!=null and Participant__r.Contact__c !=null and HCP__r.HCP_Contact__c!=null limit 1];
            toCreateUser.put(pe.Participant__r.Contact__c, pe.HCP__r.HCP_Contact__c);
            Set<Id> participantContactIds = new Set<Id>();
            Set<Id> peIds = new Set<Id>();
            peIds.add(pe.Id);
            participantContactIds.add(pe.Participant__r.Contact__c);
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                            .createParticipantUsersAsync(toCreateUser, participantContactIds, peIds);
        }catch(Exception ex){}
    }
}