/**
 * Created by Igor Malyuta on 17.04.2019.
 */

trigger TermsAndConditionsTrigger on Terms_And_Conditions__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    
    if(trigger.isafter && (trigger.isInsert || trigger.isUpdate)){
    Map<Id,Terms_And_Conditions__c> ppMap =  new  Map<Id,Terms_And_Conditions__c>();
    List<id> privacyPolicyRecordIds= new List<id>();
    for( Id tcId : Trigger.newMap.keySet() )
    {   if(trigger.isUpdate){
            if( ((Trigger.oldMap.get( tcId ).T_C_Text__c != Trigger.newMap.get( tcId ).T_C_Text__c) || (Trigger.oldMap.get( tcId ).Last_Updated_on__c != Trigger.newMap.get( tcId ).Last_Updated_on__c) ) && Trigger.newMap.get( tcId ).T_C_Type__c == 'Privacy Policy' )
            {
                ppMap.put(tcId, Trigger.newMap.get( tcId ));
                privacyPolicyRecordIds.add(tcId);
            }
        }
        else if(trigger.isInsert){
            if(Trigger.newMap.get( tcId ).T_C_Type__c == 'Privacy Policy' )
            {
                ppMap.put(tcId, Trigger.newMap.get( tcId ));
                privacyPolicyRecordIds.add(tcId);
            }
        }
    }
    TermsAndConditionsTriggerHandler th= new TermsAndConditionsTriggerHandler();
    if(!ppMap.isEmpty()){
        //th.generateTCPDF(ppMap);
        TermsAndConditionsTriggerHandler.generatePDF(privacyPolicyRecordIds);
    }
    }
    
    TriggerHandlerExecutor.execute(
        TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class
    );
}