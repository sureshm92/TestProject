/**
 * Created by Leonid Bartenev
 */

trigger PSEStatusHistoryProcess on PSE_Status_History__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    //deprecated
}
