/**
* Created by Akanksha on 18.06.20
*/
public class CCStaffTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------
        
    public class UpdateContactOnStatusChange extends TriggerHandler {
        
        public override void afterInsert(List<SObject> newList) {
            UpdateContactCCStaffStatus(newList);
        }
        public override void afterUpdate(List<SObject> newList,Map<Id, SObject> oldMap) {
            UpdateContactCCStaffStatus(newList);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void UpdateContactCCStaffStatus(List<CC_Staff__c> newList) {
        List<Contact> conList = new List<Contact>();
        List<CC_Staff__c> ccList = [SELECT Id,CC_Staff_Status__c,
                                    Contact__r.userCommunityMode__c,
                                    Contact__r.userCommunytyType__c,
                                    Contact__r.CC_Staff_Status__c
                                    FROM CC_Staff__c
                                    WHERE ID IN: newList AND
                                   Contact__r.userCommunityMode__c = 'CC'];
        For(CC_Staff__c c: ccList){
                    c.Contact__r.userCommunytyType__c = 'CC';
                if(c.CC_Staff_Status__c == 'Invited')
                    c.Contact__r.CC_Staff_Status__c = True;  
                else
                    c.Contact__r.CC_Staff_Status__c = False; 
            
            conList.add(c.Contact__r);
        }
        update conList;
    }
}