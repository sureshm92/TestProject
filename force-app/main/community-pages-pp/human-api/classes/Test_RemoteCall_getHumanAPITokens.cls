@IsTest
public class Test_RemoteCall_getHumanAPITokens {
    
    
  @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    
     @IsTest
    static void testMethod1() {
         TestData td = new TestData();
        
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 

       
        System.runAs(td.participantUser) {
            System.debug('participant:::'+td.participant);
       // Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
      // obj.remoteCallGetAccessToken('refid','part1@email.com','humanid');
     
         obj.parseNewUserSessionResponse('{"expires_in":3600,"human_id":"ee90829a2b1d2b4ab6f4903e081d9baa","session_token":"eyJraWQiOiJBYk1YS09nR3F0NGptcVZDRXo5SDlYRFIyeVo3bjRuc1RhNzFXTFVORmFBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmVLUXh5Ri1DSGY5Y1lmanZvdng1STRHWmItcGVmT1U0bl9lX2RrOV9XVWMiLCJpc3MiOiJodHRwczovL2h1bWFuYXBpLm9rdGEuY29tL29hdXRoMi9hdXN1bHY5d2tjcEx5UDJEZDI5NiIsImF1ZCI6ImNvLmh1bWFuYXBpLnByb2R1Y3Rpb24iLCJpYXQiOjE2MzAzMTcwMjIsImV4cCI6MTYzMDMyMDYyMiwiY2lkIjoiMG9hdWx2aWRxdE5VeUZlYkoyOTYiLCJ1aWQiOiIwMHU5bG85Z2F5WHI1ZElZSTI5NyIsInNjcCI6WyJhbm9ueW1vdXMiXSwic3ViIjoiYW5vbi11c2VyK2U1ZGU3ZGNkLTcwYzYtNDZkNi1hN2FjLWZkYjU5MjgxZWE0MkBub3QuaHVtYW5hcGkuY28iLCJjbGllbnRJZCI6IjcyY2QxZjFmN2IzNmNjODBlMTA0ZWZkMmE5MzMyZTc0MzcyZmNiMjQiLCJodW1hbklkIjoiZWU5MDgyOWEyYjFkMmI0YWI2ZjQ5MDNlMDgxZDliYWEiLCJncm91cHMiOlsiZW5kdXNlcnNfYW5vbnltb3VzIl0sInVzZXJJZCI6IjYxMmNhOWRkZDQ0MDVlZmZiYWIwM2MyOCJ9.JoomT54wj9O73tFpXfpeftH1FT3m25KFZ3AFXKu0QhEs-IIBg-w_Cj82KGqyAnY0KZ15Za1HQxD1QwhTEByUySQJHfxN1WGP20Nw7c8VEti5kj_-lHPMGtVK1ZBzgPl5H7yv_8kyQjSyUCrBTjGdRm0--uPcchZrUej_e-1PrBOEnWw10VOAtOG-uIXp_P6hFS2kSMgfieFGgc-FzT9L7iXGTtyLgWqnJkkxjeUh06DIOnh7Bkqo0wUBAbSlfU87fzWx6UpNKXJ83gj_wK8HLx0Q4ylm9QQFXjSfgHYjAZL_sriPTyaPxb9PfjpsxxohDrqS8SOAZxfbKcU1gtqmFg"}');
        
        }
         Test.stopTest();
         
    }
    
    @IsTest
    static void testMethod2() {
         TestData td = new TestData();
        
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 

       
        System.runAs(td.participantUser) {
            System.debug('participant:::'+td.participant);
       // Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
      // obj.remoteCallGetSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
       obj.remoteCallGetAccessToken('refid','part1@email.com','humanid');
            // obj.parseNewUserSessionResponse('{"expires_in":3600,"human_id":"ee90829a2b1d2b4ab6f4903e081d9baa","session_token":"eyJraWQiOiJBYk1YS09nR3F0NGptcVZDRXo5SDlYRFIyeVo3bjRuc1RhNzFXTFVORmFBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmVLUXh5Ri1DSGY5Y1lmanZvdng1STRHWmItcGVmT1U0bl9lX2RrOV9XVWMiLCJpc3MiOiJodHRwczovL2h1bWFuYXBpLm9rdGEuY29tL29hdXRoMi9hdXN1bHY5d2tjcEx5UDJEZDI5NiIsImF1ZCI6ImNvLmh1bWFuYXBpLnByb2R1Y3Rpb24iLCJpYXQiOjE2MzAzMTcwMjIsImV4cCI6MTYzMDMyMDYyMiwiY2lkIjoiMG9hdWx2aWRxdE5VeUZlYkoyOTYiLCJ1aWQiOiIwMHU5bG85Z2F5WHI1ZElZSTI5NyIsInNjcCI6WyJhbm9ueW1vdXMiXSwic3ViIjoiYW5vbi11c2VyK2U1ZGU3ZGNkLTcwYzYtNDZkNi1hN2FjLWZkYjU5MjgxZWE0MkBub3QuaHVtYW5hcGkuY28iLCJjbGllbnRJZCI6IjcyY2QxZjFmN2IzNmNjODBlMTA0ZWZkMmE5MzMyZTc0MzcyZmNiMjQiLCJodW1hbklkIjoiZWU5MDgyOWEyYjFkMmI0YWI2ZjQ5MDNlMDgxZDliYWEiLCJncm91cHMiOlsiZW5kdXNlcnNfYW5vbnltb3VzIl0sInVzZXJJZCI6IjYxMmNhOWRkZDQ0MDVlZmZiYWIwM2MyOCJ9.JoomT54wj9O73tFpXfpeftH1FT3m25KFZ3AFXKu0QhEs-IIBg-w_Cj82KGqyAnY0KZ15Za1HQxD1QwhTEByUySQJHfxN1WGP20Nw7c8VEti5kj_-lHPMGtVK1ZBzgPl5H7yv_8kyQjSyUCrBTjGdRm0--uPcchZrUej_e-1PrBOEnWw10VOAtOG-uIXp_P6hFS2kSMgfieFGgc-FzT9L7iXGTtyLgWqnJkkxjeUh06DIOnh7Bkqo0wUBAbSlfU87fzWx6UpNKXJ83gj_wK8HLx0Q4ylm9QQFXjSfgHYjAZL_sriPTyaPxb9PfjpsxxohDrqS8SOAZxfbKcU1gtqmFg"}');
        
        }
         Test.stopTest();
         
    }
    
    
      @IsTest
    static void testMethod3() {
        
         TestData td = new TestData();
        
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
        
        Token__c token = new Token__c(Participant_Enrollment__c = td.pe.Id ,Token_Type__c = 'session' , Token_Value__c = 'token' , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        insert token; 
       
        System.runAs(td.participantUser) {
           // td.pe = null;
            System.debug('participant:::'+td.pe);
          //  Participant_Enrollment__c pe = td.pe;
          //  pe.Referral_ID__c='sss';
          //  update pe;
            RemoteCall_getHumanAPITokens.humanId = 'humanId';
       // Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com',td.pe.Id,'humanId','uniqueHumanId');
      // obj.remoteCallGetAccessToken('refid','part1@email.com','humanid');
     
        // obj.parseNewUserSessionResponse('{"expires_in":3600,"human_id":"ee90829a2b1d2b4ab6f4903e081d9baa","session_token":"eyJraWQiOiJBYk1YS09nR3F0NGptcVZDRXo5SDlYRFIyeVo3bjRuc1RhNzFXTFVORmFBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmVLUXh5Ri1DSGY5Y1lmanZvdng1STRHWmItcGVmT1U0bl9lX2RrOV9XVWMiLCJpc3MiOiJodHRwczovL2h1bWFuYXBpLm9rdGEuY29tL29hdXRoMi9hdXN1bHY5d2tjcEx5UDJEZDI5NiIsImF1ZCI6ImNvLmh1bWFuYXBpLnByb2R1Y3Rpb24iLCJpYXQiOjE2MzAzMTcwMjIsImV4cCI6MTYzMDMyMDYyMiwiY2lkIjoiMG9hdWx2aWRxdE5VeUZlYkoyOTYiLCJ1aWQiOiIwMHU5bG85Z2F5WHI1ZElZSTI5NyIsInNjcCI6WyJhbm9ueW1vdXMiXSwic3ViIjoiYW5vbi11c2VyK2U1ZGU3ZGNkLTcwYzYtNDZkNi1hN2FjLWZkYjU5MjgxZWE0MkBub3QuaHVtYW5hcGkuY28iLCJjbGllbnRJZCI6IjcyY2QxZjFmN2IzNmNjODBlMTA0ZWZkMmE5MzMyZTc0MzcyZmNiMjQiLCJodW1hbklkIjoiZWU5MDgyOWEyYjFkMmI0YWI2ZjQ5MDNlMDgxZDliYWEiLCJncm91cHMiOlsiZW5kdXNlcnNfYW5vbnltb3VzIl0sInVzZXJJZCI6IjYxMmNhOWRkZDQ0MDVlZmZiYWIwM2MyOCJ9.JoomT54wj9O73tFpXfpeftH1FT3m25KFZ3AFXKu0QhEs-IIBg-w_Cj82KGqyAnY0KZ15Za1HQxD1QwhTEByUySQJHfxN1WGP20Nw7c8VEti5kj_-lHPMGtVK1ZBzgPl5H7yv_8kyQjSyUCrBTjGdRm0--uPcchZrUej_e-1PrBOEnWw10VOAtOG-uIXp_P6hFS2kSMgfieFGgc-FzT9L7iXGTtyLgWqnJkkxjeUh06DIOnh7Bkqo0wUBAbSlfU87fzWx6UpNKXJ83gj_wK8HLx0Q4ylm9QQFXjSfgHYjAZL_sriPTyaPxb9PfjpsxxohDrqS8SOAZxfbKcU1gtqmFg"}');
        
        }
         Test.stopTest();
         
    }
    
    @IsTest
    static void testMethod4() { 
        
        System.debug(':::testMethod4:::');
         TestData td = new TestData();
        
         Test.startTest(); 
        
        
        
        Token__c token = new Token__c(Participant_Enrollment__c = td.pe.Id ,Token_Type__c = 'session' , Token_Value__c = 'token' , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        insert token; 
       
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
           // td.pe = null;
            System.debug('participant:::'+td.pe);
            Participant_Enrollment__c pe = td.pe;
            pe.Referral_ID__c=td.pe.Name;
           update pe;
          //  RemoteCall_getHumanAPITokens.humanId = 'humanId';
       // Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
       
       RemoteCall_getHumanAPITokens obj = new RemoteCall_getHumanAPITokens();
       RemoteCall_getHumanAPITokens.getInstance();
       
       obj.remoteCallGetSessionToken('part1@email.com',td.pe.Id,'humanId','uniqueHumanId');
      // obj.remoteCallGetAccessToken('refid','part1@email.com','humanid');
     
        // obj.parseNewUserSessionResponse('{"expires_in":3600,"human_id":"ee90829a2b1d2b4ab6f4903e081d9baa","session_token":"eyJraWQiOiJBYk1YS09nR3F0NGptcVZDRXo5SDlYRFIyeVo3bjRuc1RhNzFXTFVORmFBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmVLUXh5Ri1DSGY5Y1lmanZvdng1STRHWmItcGVmT1U0bl9lX2RrOV9XVWMiLCJpc3MiOiJodHRwczovL2h1bWFuYXBpLm9rdGEuY29tL29hdXRoMi9hdXN1bHY5d2tjcEx5UDJEZDI5NiIsImF1ZCI6ImNvLmh1bWFuYXBpLnByb2R1Y3Rpb24iLCJpYXQiOjE2MzAzMTcwMjIsImV4cCI6MTYzMDMyMDYyMiwiY2lkIjoiMG9hdWx2aWRxdE5VeUZlYkoyOTYiLCJ1aWQiOiIwMHU5bG85Z2F5WHI1ZElZSTI5NyIsInNjcCI6WyJhbm9ueW1vdXMiXSwic3ViIjoiYW5vbi11c2VyK2U1ZGU3ZGNkLTcwYzYtNDZkNi1hN2FjLWZkYjU5MjgxZWE0MkBub3QuaHVtYW5hcGkuY28iLCJjbGllbnRJZCI6IjcyY2QxZjFmN2IzNmNjODBlMTA0ZWZkMmE5MzMyZTc0MzcyZmNiMjQiLCJodW1hbklkIjoiZWU5MDgyOWEyYjFkMmI0YWI2ZjQ5MDNlMDgxZDliYWEiLCJncm91cHMiOlsiZW5kdXNlcnNfYW5vbnltb3VzIl0sInVzZXJJZCI6IjYxMmNhOWRkZDQ0MDVlZmZiYWIwM2MyOCJ9.JoomT54wj9O73tFpXfpeftH1FT3m25KFZ3AFXKu0QhEs-IIBg-w_Cj82KGqyAnY0KZ15Za1HQxD1QwhTEByUySQJHfxN1WGP20Nw7c8VEti5kj_-lHPMGtVK1ZBzgPl5H7yv_8kyQjSyUCrBTjGdRm0--uPcchZrUej_e-1PrBOEnWw10VOAtOG-uIXp_P6hFS2kSMgfieFGgc-FzT9L7iXGTtyLgWqnJkkxjeUh06DIOnh7Bkqo0wUBAbSlfU87fzWx6UpNKXJ83gj_wK8HLx0Q4ylm9QQFXjSfgHYjAZL_sriPTyaPxb9PfjpsxxohDrqS8SOAZxfbKcU1gtqmFg"}');
        
        }
         Test.stopTest();
         
    }
    

}