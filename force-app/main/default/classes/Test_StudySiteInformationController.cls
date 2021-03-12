@isTest 
public class Test_StudySiteInformationController {
    
    public static List<Account> acclist = TestData_StudySiteInformationController.createacclistdata();
    public static List<contact> conlist = TestData_StudySiteInformationController.createcontactlistdata();
    public static List<Clinical_Trial_Profile__c> CTPlist = TestData_StudySiteInformationController.createCTPlistdata();
    public static List<Study_Site__c> studylist = TestData_StudySiteInformationController.createstudylist();
    public static List<SelectOption> countries = TestData_StudySiteInformationController.getItems();  
    public static List<Site_Staff__c> stafflist = TestData_StudySiteInformationController.createstafflist();     
    public static List<Participant__c> parlist = TestData_StudySiteInformationController.createparlist();     
    
    static testmethod void testmethods(){
        StudySiteInformationController.SiteWrapper ssw = new StudySiteInformationController.SiteWrapper();
        StudySiteInformationController.InitData ind; 
        Id accid = acclist[0].Id;	
        string callDisp='{"callbound":"Inbound","callcategory":"Welcome Call Complete","interventionReq":false,"notes":""}';        
        SiteListPageRemote.SiteWrapper Wrapper= SiteListPageRemote.wrapperTransformation(studylist)[0];
        String studySiteInfo = JSON.serialize(Wrapper);
        
        test.startTest();
        StudySiteInformationController.getAccountData(conlist[1].ID);       
        StudySiteInformationController.getDelegateMap(studylist[0].Id);        
        try {
            StudySiteInformationController.saveSSChanges(studySiteInfo, accid, callDisp, true);              
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }        
        test.stopTest();
        
    }
}