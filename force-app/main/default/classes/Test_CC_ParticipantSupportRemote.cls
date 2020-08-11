@IsTest
public class Test_CC_ParticipantSupportRemote {
  
    @IsTest
    static void testfetchParticipantEnrollment() {
     
        contact cont = new contact();
        cont.Email='test@iqvia.com';
        cont.LastName='NewContact';
        insert cont;
        
        Test.startTest();
          try {
             CC_ParticipantSupportRemote.getInvitedDetails(cont.id);
            } catch (exception e) {}
        
        Test.stopTest();
    }
    
}