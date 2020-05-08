public class CaseCreator {
    @InvocableMethod
    public static void createCase(){
        Case newCase = new Case();
        newCase.Origin = 'Web';
        newCase.Priority = 'High';
        newCase.Reason = 'Lockout - Unable to login';
        newCase.Status = 'New';
        newCase.Type = 'Issue';
        newCase.Subject = 'Lockout - unable to login';
        List<User> caseOwner = [select Id from User where  email =:Label.Case_Owner_Email_For_User_Lockout];
        if(caseOwner.size()>0)
        newCase.OwnerId = caseOwner[0].Id;
        insert newCase;
    }
}