public class HumanAPIWrapper {
    
    @AuraEnabled
    public List<LabelValueItem> referrals;
    @AuraEnabled
    public String currentContactId;
    @AuraEnabled
    public String currentPerId;
    @AuraEnabled 
    public String communityName;
    @AuraEnabled
    public String currentPerStatus = 'PARTICIPANT';
    @AuraEnabled
    public Boolean iscurrentPresent = false;
    
}