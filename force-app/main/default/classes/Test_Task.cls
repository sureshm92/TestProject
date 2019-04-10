/**
 * Created by mkotenev on 2/27/2019.
 */

@IsTest
public with sharing class Test_Task {

    @IsTest public static void testCheckTask() {

        String taskCatalogName = 'Complete_Your_Profile';
        String expectedSubject = 'Dear Conon Barbar, please, complete your Patient Profile';

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
                Last_Name__c='Barbar',
                Contact__c=contact.Id);
        insert participant;

        Participant__c dbParticipant = [
                SELECT
                        Condition_of_Interest_s__c,
                        Contact__c,
                        Country__c,
                        Country_Code__c,
                        CreatedById,
                        CreatedDate,
                        Email__c,
                        First_Name__c,
                        Full_Name__c,
                        Id,
                        IsCountry_NOT_Eligible_for_Emails__c,
                        IsDeleted,
                        Language_Preference__c,
                        Language_Preference_Code__c,
                        Last_Name__c,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Mailing_City__c,
                        Mailing_Country__c,
                        Mailing_Country_Code__c,
                        Mailing_State__c,
                        Mailing_State_Code__c,
                        Mailing_State_Province__c,
                        Mailing_Street__c,
                        Mailing_Zip_Postal_Code__c,
                        Name,
                        OwnerId,
                        Phone__c,
                        SystemModstamp,
                        ZIP_Code__c
                FROM Participant__c WHERE Id =: participant.Id];

        System.debug('###dbParticipant: ' + dbParticipant);

        Task task = new Task(
                Task_Code__c=taskCatalogName,
                Subject='Other',
                Priority='Normal',
                Status='Open',
                WhatId = dbParticipant.Id,
                OwnerId=Id.valueOf(UserInfo.getUserId())
        );
        insert task;

        Map<String, String> labelValues = new Map<String, String>();
        labelValues.put('Task_Subject_Complete_Your_Profile', 'Dear ##ParticipantName, please, complete your Patient Profile');
        TranslateHelper.labelValuesMap.put(UserInfo.getLanguage(), labelValues);

        List<Task> listTasks = new List<Task>();
        listTasks.add(task);

        TaskTriggerHandler.processDefaultFieldValues(listTasks);
        Test.startTest();
        System.assertEquals(expectedSubject, listTasks.get(0).Subject);
        System.assertEquals(null, listTasks.get(0).Description);
        Test.stopTest();
    }
}