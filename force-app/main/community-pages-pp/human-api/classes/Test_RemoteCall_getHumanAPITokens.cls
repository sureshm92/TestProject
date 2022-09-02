@IsTest
public class Test_RemoteCall_getHumanAPITokens {
    
    
  @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    
     @IsTest
    static void testMethod1() {
        // TestData td = new TestData();
       Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        List<String> contactLastNames = new List<String>{
            participant.Name,
            'HCPTD',
            'PITD',
            'HCPDelTD',
            'PIDelTD',
            'CCID'
        };
        List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName IN :contactLastNames
        ];
        User participantUser;
        for (User user : users) {
            if (user.LastName == participant.Name) 
                participantUser = user;
            
        }
        
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 

       
        System.runAs(participantUser) {
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
     
         obj.parseNewUserSessionResponse('{"expires_in":3600,"human_id":"ee90829a2b1d2b4ab6f4903e081d9baa","session_token":"eyJraWQiOiJBYk1YS09nR3F0NGptcVZDRXo5SDlYRFIyeVo3bjRuc1RhNzFXTFVORmFBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmVLUXh5Ri1DSGY5Y1lmanZvdng1STRHWmItcGVmT1U0bl9lX2RrOV9XVWMiLCJpc3MiOiJodHRwczovL2h1bWFuYXBpLm9rdGEuY29tL29hdXRoMi9hdXN1bHY5d2tjcEx5UDJEZDI5NiIsImF1ZCI6ImNvLmh1bWFuYXBpLnByb2R1Y3Rpb24iLCJpYXQiOjE2MzAzMTcwMjIsImV4cCI6MTYzMDMyMDYyMiwiY2lkIjoiMG9hdWx2aWRxdE5VeUZlYkoyOTYiLCJ1aWQiOiIwMHU5bG85Z2F5WHI1ZElZSTI5NyIsInNjcCI6WyJhbm9ueW1vdXMiXSwic3ViIjoiYW5vbi11c2VyK2U1ZGU3ZGNkLTcwYzYtNDZkNi1hN2FjLWZkYjU5MjgxZWE0MkBub3QuaHVtYW5hcGkuY28iLCJjbGllbnRJZCI6IjcyY2QxZjFmN2IzNmNjODBlMTA0ZWZkMmE5MzMyZTc0MzcyZmNiMjQiLCJodW1hbklkIjoiZWU5MDgyOWEyYjFkMmI0YWI2ZjQ5MDNlMDgxZDliYWEiLCJncm91cHMiOlsiZW5kdXNlcnNfYW5vbnltb3VzIl0sInVzZXJJZCI6IjYxMmNhOWRkZDQ0MDVlZmZiYWIwM2MyOCJ9.JoomT54wj9O73tFpXfpeftH1FT3m25KFZ3AFXKu0QhEs-IIBg-w_Cj82KGqyAnY0KZ15Za1HQxD1QwhTEByUySQJHfxN1WGP20Nw7c8VEti5kj_-lHPMGtVK1ZBzgPl5H7yv_8kyQjSyUCrBTjGdRm0--uPcchZrUej_e-1PrBOEnWw10VOAtOG-uIXp_P6hFS2kSMgfieFGgc-FzT9L7iXGTtyLgWqnJkkxjeUh06DIOnh7Bkqo0wUBAbSlfU87fzWx6UpNKXJ83gj_wK8HLx0Q4ylm9QQFXjSfgHYjAZL_sriPTyaPxb9PfjpsxxohDrqS8SOAZxfbKcU1gtqmFg"}');
        
        }
         Test.stopTest();
         
    }
    
    @IsTest
    static void testMethod2() {
                         Participant_Enrollment__c pe=[Select Id from Participant_Enrollment__c where Screening_ID__c='PESCR1' LIMIT 1];

       Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        List<String> contactLastNames = new List<String>{
            participant.Name,
            'HCPTD',
            'PITD',
            'HCPDelTD',
            'PIDelTD',
            'CCID'
        };
        List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName IN :contactLastNames
        ];
        User participantUser;
        for (User user : users) {
            if (user.LastName == participant.Name) 
                participantUser = user;
            
        }
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 

       
        System.runAs(participantUser) {
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetAccessToken('refid','part1@email.com','humanid');
        
        }
         Test.stopTest();
         
    }
    
    
      @IsTest
    static void testMethod3() {
                Participant_Enrollment__c pe=[Select Id from Participant_Enrollment__c where Screening_ID__c='PESCR1' LIMIT 1];

        
       Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        List<String> contactLastNames = new List<String>{
            participant.Name,
            'HCPTD',
            'PITD',
            'HCPDelTD',
            'PIDelTD',
            'CCID'
        };
        List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName IN :contactLastNames
        ];
        User participantUser;
        for (User user : users) {
            if (user.LastName == participant.Name) 
                participantUser = user;
            
        }
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
        
        Token__c token = new Token__c(Participant_Enrollment__c = pe.Id ,Token_Type__c = 'session' , Token_Value__c = 'token' , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        insert token; 
       
        System.runAs(participantUser) {
           
            RemoteCall_getHumanAPITokens.humanId = 'humanId';
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com',pe.Id,'humanId','uniqueHumanId');
     
        
        }
         Test.stopTest();
         
    }
    
    @IsTest
    static void testMethod4() { 
                               
       Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        List<String> contactLastNames = new List<String>{
            participant.Name,
            'HCPTD',
            'PITD',
            'HCPDelTD',
            'PIDelTD',
            'CCID'
        };
        List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName IN :contactLastNames
        ];
        User participantUser;
        for (User user : users) {
            if (user.LastName == participant.Name) 
                participantUser = user;
            
        }
        
         Test.startTest(); 
        
         Participant_Enrollment__c pe=[Select Id,Name from Participant_Enrollment__c where Screening_ID__c='PESCR2' LIMIT 1];
        pe.Referral_ID__c=pe.Name;
        update pe;
        
        Token__c token = new Token__c(Participant_Enrollment__c = pe.Id ,Token_Type__c = 'session' , Token_Value__c = 'token' , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        insert token; 
       
        System.runAs(participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
           
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com',pe.Id,'humanId','uniqueHumanId');
     
        
        }
         Test.stopTest();
         
    }
    

}