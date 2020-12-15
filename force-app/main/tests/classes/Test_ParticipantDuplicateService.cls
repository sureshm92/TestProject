/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_ParticipantDuplicateService {
    @IsTest
    static void test() {
        insert new Account(Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME);
        Participant__c participantWithBY = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1980',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com',
                ZIP_Code__c = '234444',
                 Mailing_Zip_Postal_Code__c = '233333',
               //  Day_of_Birth__c = date.today().addyears(-20),
                Day_of_Birth__c = date.today().addyears(-20),
                Adult__c = false
        );
        insert participantWithBY;

        Participant__c participantWithoutBY = new Participant__c(
                First_Name__c = 'Jane',
                Last_Name__c = 'Goodwin',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'JaneGoodwin@mail.com',
                Phone__c = '123456789',
                  ZIP_Code__c = '234444',
                Day_of_Birth__c = date.today().addyears(-20),
                Adult__c = false
        );
        insert participantWithoutBY;

        Participant__c participantDiffPhonesSameEmails = new Participant__c(
                First_Name__c = 'Diff',
                Last_Name__c = 'Phones',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                 Mailing_Zip_Postal_Code__c = '233333',
                Email__c = 'diffphones@mail.com',
                Phone__c = '7777777',
                  ZIP_Code__c = '234444',
                Day_of_Birth__c = date.today().addyears(-20),
                Adult__c = false
        );
        insert participantDiffPhonesSameEmails;

        Test.startTest();
        Participant__c noBirthYearFirstNameMatch = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com',
                  ZIP_Code__c = '234444',
                   Mailing_Zip_Postal_Code__c = '233333',
                Day_of_Birth__c = date.today().addyears(-20),
                Adult__c = true
        );
    
        Participant__c noBirthYearFirstNameNotMatch = new Participant__c(
                First_Name__c = 'Maximus',
                Last_Name__c = 'James',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com',
                Adult__c = false
        );
    
        Participant__c withBirthYear = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                  ZIP_Code__c = '234444',
                Day_of_Birth__c = date.today().addyears(-20),
                Birth_Year__c = '1980',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                 Mailing_Zip_Postal_Code__c = '233333',
                Email__c = 'MaxJames@mail.com',
                Adult__c = true
        );
    
        Participant__c withBirthYearButNoBYInTheInTheSystemAgeMore18 = new Participant__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Goodwin',
            Date_of_Birth__c = '1980-01-01',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'NY',
            Phone__c = '123456789',
            Adult__c = true
        );

        Participant__c withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch = new Participant__c(
                First_Name__c = 'Janny',
                Last_Name__c = 'Goodween',
                Date_of_Birth__c = '1980-01-01',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                  ZIP_Code__c = '234444',
                   Mailing_Zip_Postal_Code__c = '233333',
                Day_of_Birth__c = date.today().addyears(-20),
                Phone__c = '123456789',
                Adult__c = true
        );
    
        Participant__c withBYButNoBYInTheInTheSystemAgeLow18 = new Participant__c(
                First_Name__c = 'Jane',
                Last_Name__c = 'Goodween',
                Birth_Year__c = '2002',
                 Mailing_Zip_Postal_Code__c = '233333',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'JaneGoodwin@mail.com',
                Adult__c = true
        );
    
        Participant__c participantDiffPhonesSameEmailsCompare = new Participant__c(
                First_Name__c = 'Diff',
                Last_Name__c = 'Phones',
                Mailing_Country_Code__c = 'US',
                Mailing_Zip_Postal_Code__c = '233333',
                Mailing_State_Code__c = 'NY',
                Email__c = 'diffphones@mail.com',
                  ZIP_Code__c = '234444',
               // Day_of_Birth__c = date.today().addyears(-20),
                Phone__c = '11111',
                Adult__c = true
        );
  
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(new List<Participant__c>{
                noBirthYearFirstNameMatch,
                noBirthYearFirstNameNotMatch,
                withBirthYear,
                withBirthYearButNoBYInTheInTheSystemAgeMore18,
                withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch,
                withBYButNoBYInTheInTheSystemAgeLow18,
                participantDiffPhonesSameEmailsCompare
        });
        
          ParticipantDuplicateService duplicateService3 = new ParticipantDuplicateService(new List<Participant__c>{
                participantWithBY ,
                participantWithoutBY ,
                withBirthYearButNoBYInTheInTheSystemAgeMore18,
                withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch,
                withBYButNoBYInTheInTheSystemAgeLow18,
                participantDiffPhonesSameEmailsCompare
        });
        
          ParticipantDuplicateService duplicateService2 = new ParticipantDuplicateService(new List<Participant__c>{
              
                withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch,
                withBYButNoBYInTheInTheSystemAgeLow18,
                participantDiffPhonesSameEmailsCompare
        });
        
         ParticipantDuplicateService duplicateService1 = new ParticipantDuplicateService(
                noBirthYearFirstNameMatch
              
        );
     //  duplicateService.getContact();
       duplicateService.findDuplicateDelegate(participantDiffPhonesSameEmailsCompare);
       duplicateService.findDuplicateDelegateContact(participantDiffPhonesSameEmailsCompare);
       
       //  List<ParticipantDuplicateService.ParticipantWithDelegate> pwd = new List<ParticipantDuplicateService.ParticipantWithDelegate>();
    
    ParticipantDuplicateService.ParticipantWithDelegate pwdd = new ParticipantDuplicateService.ParticipantWithDelegate();
    pwdd.participant = participantDiffPhonesSameEmailsCompare;
    pwdd.delegate = withBYButNoBYInTheInTheSystemAgeLow18;
    new ParticipantDuplicateService(new List<ParticipantDuplicateService.ParticipantWithDelegate>{pwdd});
     new ParticipantDuplicateService(pwdd);
     duplicateService.findDuplicateContact(participantDiffPhonesSameEmailsCompare);
    
  //  ParticipantDuplicateService
  //  List<ParticipantDuplicateService.ParticipantWithDelegate> pwd1 = new List<ParticipantDuplicateService.ParticipantWithDelegate>();  
    
       
       
       
        Test.stopTest();

        System.assert(
            duplicateService.findDuplicate(noBirthYearFirstNameMatch) != null,
            'Case: "No BirthYear, First name match". Duplicate must be found for ' +
            JSON.serializePretty(noBirthYearFirstNameMatch)
        );
        System.assert(
            duplicateService.findDuplicate(noBirthYearFirstNameNotMatch) == null,
            'Case: "No BirthYear, First name not match". No duplicate must be found for: ' +
            JSON.serializePretty(noBirthYearFirstNameNotMatch)
        );
        System.assert(
            duplicateService.findDuplicate(withBirthYear) != null,
            'Case: "With BirthYear, BirthYear exists in the system, First name match". Duplicate must be found for: ' +
            JSON.serializePretty(withBirthYear)
        );
        System.assert(
            duplicateService.findDuplicate(withBirthYearButNoBYInTheInTheSystemAgeMore18) != null,
            'Case: "With BirthYear, No BirthYear in the system, Age > 18, Name match". Duplicate must be found for: ' +
            JSON.serializePretty(withBirthYearButNoBYInTheInTheSystemAgeMore18)
        );
        System.assert(
            duplicateService.findDuplicate(withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch) ==
            null,
            'Case: "With BirthYear, No BirthYear in the system, Age > 18, Name not match". No duplicate must be found for: ' +
            JSON.serializePretty(withBYButNoBYInTheInTheSystemAgeMore18NameNotMatch)
        );
        System.assert(
            duplicateService.findDuplicate(withBYButNoBYInTheInTheSystemAgeLow18) == null,
            'Case "With BirthYear, No BirthYear in the system, Age <= 18". No duplicate must be found for: ' +
            JSON.serializePretty(withBYButNoBYInTheInTheSystemAgeLow18)
        );
        System.assert(
            duplicateService.findDuplicate(participantDiffPhonesSameEmailsCompare) != null,
            'Case "Different emails, same phones". Duplicate must be found' +
            JSON.serializePretty(withBYButNoBYInTheInTheSystemAgeLow18)
        );
    }
}