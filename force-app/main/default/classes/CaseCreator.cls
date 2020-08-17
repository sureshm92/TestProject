public class CaseCreator {
    @InvocableMethod
    public static void createCase(List<Id> contactIds){
        List<Group> groupList=[SELECT Id,Name FROM Group WHERE developerName=:OptOutAndTechnicalSupport.TECH_SUPPORT_QUEUE_NAME LIMIT 1];
        List<Case> newCases = new List<Case>();
        for(Id contactId : contactIds){
            Case newCase = new Case();
            newCase.Origin = 'Web';
            newCase.Priority = 'High';
            newCase.Reason = 'Lockout - Unable to login';
            newCase.Status = 'New';
            newCase.Type = 'Issue';
            newCase.ContactId = contactId;
            // Workflow rule and Flow dependent on Subject
            newCase.Subject = 'Lockout - unable to login';
            if(groupList.size()>0){
                newCase.OwnerId = groupList[0].Id;
            }
            newCases.add(newCase);
        }
        insert newCases;
    }
}