@IsTest
public class Test_DelegateService {
    
     @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createPIDelegateUser();
        List<Site_Staff__c> lstSiteStaf = new List<Site_Staff__c> ();
        for(Site_Staff__c piStaffs : [SELECT Id,  is_Invited__c FROM Site_Staff__c])
        {
            piStaffs.is_Invited__c = true;
            lstSiteStaf.add(piStaffs);
        }
        update lstSiteStaf;
        Test.stopTest();
    }
    
    @istest
    public static void testMethod1(){
        contact objcon = [SELECT ID FROM Contact where FirstName = 'PITD' AND Email = 'pi@emil.com' LIMIT 1];
        User objUser = [SELECT ID FROM user where contactId =:objcon.id];
        Study_Site__c objStudySite = [SELECT ID FROM Study_Site__c WHERE Principal_Investigator__c =:objcon.Id LIMIT 1];
         List<Site_Staff__c> piStaffs = [SELECT Id, Study_Site__c, Study_Site__r.Principal_Investigator__c,
                                            Study_Site__r.Clinical_Trial_Profile__c, Delegate_Level__c, Clinical_Trial_Profile__c,
                                            Site_Contact__c, is_Invited__c FROM Site_Staff__c
                                			WHERE (Site_Contact__c = :objcon.Id
                                        		OR Study_Site__r.Principal_Investigator__c = :objcon.Id) AND is_Invited__c = TRUE];
        system.runAs(objUser)
        {
            DelegateService objDelegateService = new DelegateService();
            DelegateService.getInstance();
              objDelegateService.getPIStudySitesAccessLevelMapImpl();
            objDelegateService.getDelegatedStudySiteIdsImpl();
            objDelegateService.getStudyPIContactsMapImpl();
            objDelegateService.getStudiesAccessLevelMapImpl('PI');
            objDelegateService.getPITeamStaffTrialMapImpl();
            objDelegateService.getPIDelegateParentsImpl();
            objDelegateService.getStudyAccessLevelImpl(objStudySite.ID,'PI');
            DelegateService.CheckAndDeactivateUsersForPI(piStaffs);
            DelegateService.addConversationSharesForPITeam(piStaffs);
            DelegateService.removeConversationSharesForPITeam(piStaffs);
        }
    }
        @istest
    public static void testMethodStaticMethods(){
        contact objcon = [SELECT ID FROM Contact where FirstName = 'PITD' AND Email = 'pi@emil.com' LIMIT 1];
        User objUser = [SELECT ID FROM user where contactId =:objcon.id];
        Study_Site__c objStudySite = [SELECT ID FROM Study_Site__c WHERE Principal_Investigator__c =:objcon.Id LIMIT 1];
        system.runAs(objUser)
        {
            DelegateService.getPIStudySitesAccessLevelMap();
            DelegateService.getDelegatedStudySiteIds();
            DelegateService.getStudyPIContactsMap();
                DelegateService.getPITeamStaffTrialMap();
                DelegateService.getStudiesAccessLevelMap('PI');
                DelegateService.getStudyAccessLevel(objStudySite.ID,'PI');
                DelegateService.getStudyAccessLevel(objStudySite.ID,'PI',null);
                DelegateService.getHCPDelegates();
                DelegateService.getHCPDelegateLevelMap();
                DelegateService.getPIDelegateParents();
            	DelegateService.updateDelegatePermissionSetsPI(objcon);
        }
        
    }
    
    @isTest
    public static void testMethodPiDelegate(){
        contact objcon = [SELECT ID FROM Contact where LastName = 'PIDelTD' AND Email = 'pi_delegate@emil.com' LIMIT 1];
        User objUser = [SELECT ID FROM user where contactId =:objcon.id];
        Set<Id> setDelegateUser = new set<Id> ();
        setDelegateUser.add(objUser.id);
         system.runAs(objUser)
        {
            DelegateService objDelegateService = new DelegateService();
            DelegateService.deactivateDelegateUsers(setDelegateUser);
            DelegateService.activateDelegateUsers(setDelegateUser);
            DelegateService.updateDelegatePermissionSetsPI(objcon);
        }
        
    }
     @isTest
    public static void testMethodHCP(){
        contact objcon = [SELECT ID FROM Contact where LastName = 'HCPTD' AND Email = 'hcp@emil.com' LIMIT 1];
        contact objconDelegate = [SELECT ID FROM Contact where LastName = 'HCPDelTD' AND Email = 'hcp_delegate@emil.com' LIMIT 1];
        User objUser = [SELECT ID FROM user where contactId =:objcon.id];
        HCP_Enrollment__c objHcpEnroll = [SELECT ID,Study_Site__c FROM HCP_Enrollment__c WHERE HCP_Contact__c =:objcon.Id LIMIT 1 ];
        
        List<RP_Delegate_Relationship__c> lstRpDelegate = [SELECT Id, Referring_Provider__r.Full_Name__c, Referring_Provider__c,
                											Delegate__c, Delegate_Access_Level__c, 
                                                           Referring_Provider__r.Salutation, Referring_Provider__r.Title, Referring_Provider__r.Suffix
               												 FROM RP_Delegate_Relationship__c WHERE Delegate__c = :objcon.Id];
         system.runAs(objUser)
        {
            DelegateService objDelegateService = new DelegateService();
            objDelegateService.getHCPDelegatesImpl();
            objDelegateService.getHCPDelegateLevelMapImpl();
             objDelegateService.getStudyAccessLevelImpl(objHcpEnroll.Study_Site__c,'HCP',objconDelegate.id);
            DelegateService.CheckAndDeactivateUsersForHCP(lstRpDelegate);
        }
        
    }

}