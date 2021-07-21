public class Batch_DeleteExpiredTokens extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,Participant_Enrollment__c,Token_Type__c,Token_Value__c,Expiration_Date__c from Token__c
                    WHERE
                    Expiration_Date__c <=:System.now()            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Token__c> tokens) {
        List<Token__c> tokensToDelete = new List<Token__c>();
        for(Token__c token :  tokens){
         tokensToDelete.add(token);
        
        }
        
       delete tokensToDelete;
    }
    public  override void finish(Database.BatchableContext BC) {
    }
    
    public override Type getType() {
        return Batch_DeleteExpiredTokens.class;
    }

    public override String getBatchDescription() {
        return 'This job delete expired session and access tokens';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}