/**
 * Created by Leonid Bartenev
 */

trigger PSEProcess on Participant_Study_Enrollment__c (after insert, after update) {
    PSETriggerHandler.processStatusHistory();
    
}