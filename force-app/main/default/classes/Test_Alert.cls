/**
 * Created by mkotenev on 2/21/2019.
 */

@isTest
public with sharing class Test_Alert {

    @isTest public static void testCheckAlert() {

        String alertCatalogName = 'Welcome_to_the_Study';
        String expectedBody = 'Congratularions Conon Varvar! You are now enrolled in the TestStudyTitle study! Additional information such as the study schedule, additional resources specific to the study, as well as tasks associated with the study will now be avaliable on the Home page. Click OK to begin!';

        Account account = new Account(
                Name='Participant');
        insert account;

        Contact contact = new Contact(
                FirstName='Maxim',
                LastName = 'Maximov',
                Email = 'maxim@maximov.maxim',
                Phone = '888-999-808',
                Language__c='en_US',
                AccountId = account.Id);
        insert contact;

        // Участник опроса
        Participant__c participant = new Participant__c(
                First_Name__c='Conon',
                Last_Name__c='Varvar',
                Contact__c=contact.Id);
        insert participant;

        Clinical_Trial_Profile__c clinicalTrialProfile = new Clinical_Trial_Profile__c(
                Protocol_ID__c='Prot-999-Maxim',
                Study_Title__c='TestStudyTitle',
                NCT_Number__c='NCT11110089');
        insert  clinicalTrialProfile;

        Study_Site__c studySite = new Study_Site__c(
                Clinical_Trial_Profile__c=clinicalTrialProfile.Id,
                Study_Site_Key__c='TestKeyMK',
                Site__c=account.Id,
                Principal_Investigator__c = contact.Id
        );
        insert studySite;

        // Регистрация участников
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Participant__c=participant.Id,
                Study_Site__c=studySite.Id);
        insert  pe;

        Alert__c dbAlert = new Alert__c(
                Alert_Code__c=alertCatalogName,
                Contact__c=contact.Id,
                Record_ID__c=pe.Id
        );
        insert dbAlert;

        Map<String, String> labelValuesForLanguage = new Map<String, String>();
        labelValuesForLanguage.put('AL_Body_Welcome_Study', 'Congratularions ##UserName! You are now enrolled in the ##StudyName study! Additional information such as the study schedule, additional resources specific to the study, as well as tasks associated with the study will now be avaliable on the Home page. Click OK to begin!');
        labelValuesForLanguage.put('AL_1buttonlabel', 'OK');
        labelValuesForLanguage.put('AL_Title_Welcome_Study', 'Welcome to the study!');
        TranslateHelper.labelValuesMap.put(UserInfo.getLanguage(), labelValuesForLanguage);

        List<Alert> alerts = Alert.getContactAlerts(contact.Id);
        System.debug('###Alerts: ' + alerts);

        Test.startTest();
        System.assertEquals(expectedBody, alerts.get(0).body);
        Test.stopTest();
    }
}