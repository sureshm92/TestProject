@isTest
public class TestData_StudySiteInformationController {
    public static List<Account> acclist;
    public static List<contact> conlist;
    public static List<Clinical_Trial_Profile__c> CTPlist;
    public static List<Study_Site__c> studylist;   
    public static List<SelectOption> options;  
    public static List<Call_Dispositions__c> calldlist;    
    public static List<Visit_Plan__c> visitlist;   
    public static List<Site_Staff__c> stafflist;
    public static List<Participant__c> parlist;    
    
    public static List<Account> createacclistdata(){
        acclist = new List<Account>();
        for(integer i =0; i<=10;i++){   
            Account testAccount = new Account();
            testAccount.Name='Test Account'+i ;
            testAccount.BillingStreet = '11 Initial Street';
            testAccount.BillingCity = 'Rochester';
            testAccount.BillingPostalCode = '12456';
            testAccount.BillingState = 'New York';
            testAccount.BillingCountry = 'United States';
            acclist.add(testAccount);
        }
        insert acclist;
        return acclist;
    }
    
    public Static List<contact> createcontactlistdata(){
        conlist = new List<contact>();
        for(integer i =0; i<=10;i++){
            contact con = new contact();
            con.FirstName = 'FirstName'+i;
            con.LastName = 'LastName'+i;
            con.AccountId = acclist[0].Id;
            conlist.add(con);
        }
        insert conlist;
        return conlist;
    }
    
    public static List<Clinical_Trial_Profile__c> createCTPlistdata(){
        
        CTPlist = new List<Clinical_Trial_Profile__c>();
        for(integer i =0; i<=10;i++){
            Clinical_Trial_Profile__c CTP = new Clinical_Trial_Profile__c();
            CTP.Age__c = 'Test' + i;
            CTP.Protocol_ID__c = 'Prot -'+i;
            CTPlist.add(CTP);
        }
        insert CTPlist;
        return CTPlist;
    }
    
    public static List<Study_Site__c> createstudylist(){
        studylist = new List<Study_Site__c>();
        for(integer i =0; i<=10;i++){
            Study_Site__c ss = new Study_Site__c();
            ss.Clinical_Trial_Profile__c = CTPlist[i].Id;
            ss.Site__c = acclist[i].Id;
            ss.Principal_Investigator__c = conlist[i].Id;
            //ss.Principal_Investigator__r.AccountId = conlist[1].AccountId;
            ss.Account_Was_Changed__c = false;
            studylist.add(ss);
        }
        insert studylist;
        system.debug('studylist'+studylist);
        return studylist;
    }
    
    public static List<Visit_Plan__c> createvisitplanlist(){
        visitlist = new List<Visit_Plan__c>();
        for(integer i=0; i<=10;i++){
            Visit_Plan__c vp = new Visit_Plan__c();
            vp.Name = 'visit Name'+i;
            vp.version__c = 'version'+i;
            visitlist.add(vp);
        }
        insert visitlist;
        return visitlist;
    }
    
    public static List<Call_Dispositions__c> createcalldislist(){
        system.debug('studylist'+studylist);
        calldlist = new List<Call_Dispositions__c>();
        for(integer i =0; i<=10;i++){
            Call_Dispositions__c cd = new Call_Dispositions__c();
            cd.Study_Site__c = studylist[0].Id;
            cd.caller__c = conlist[0].Id;
            cd.Call_Category__c = 'No Answer';   
            calldlist.add(cd);
        }
        insert calldlist;
        return calldlist;
    } 
    
    public static List<Site_Staff__c> createstafflist(){
        stafflist = new List<Site_Staff__c>();
        for(integer i =0; i<=10;i++){
            Site_Staff__c ss = new Site_Staff__c();
            ss.Site_Contact__c = conlist[0].Id;
            ss.Study_Site__c = studylist[0].Id;  
            ss.Delegate_Level__c = 'Level 1';    
            stafflist.add(ss);
        }
        
        insert stafflist;
        return stafflist;
    }
    
    public static List<Participant__c> createparlist(){
        parlist = new List<Participant__c>();
        for(integer i =0; i<=10;i++){
            Participant__c p =new Participant__c();
            p.Contact__c = conlist[i].Id;
            p.Site__c = acclist[i].Id;
            parlist.add(p);
        }
        insert parlist;
        return parlist;
    }
    
    
    public static List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AF','Afghanistan'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO','Mexico'));
        return options;
    }
}