/**
 * Created by user on 04-Jul-19.
 */

trigger PatientVisitResultTrigger on Visit_Result__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
}
