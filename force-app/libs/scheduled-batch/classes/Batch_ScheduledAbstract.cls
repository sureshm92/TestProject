/**
 * Created by Igor Malyuta on 31.05.2019.
 */ 

public abstract class Batch_ScheduledAbstract implements Database.Batchable<SObject>, Database.Stateful {
    public static final String INTERVAL_MINUTES = 'Minutes';
    public static final String INTERVAL_HOURS = 'Hours';
    public static final String INTERVAL_DAYS = 'Days';
    public static final String INTERVAL_WEEKS = 'Weeks';
    public static final String INTERVAL_MONTHS = 'Months';
	public Boolean skipRelaunch = false;
    public abstract Type getType();

    /**
     * Description of the purpose of this batch to display on the panel
     */
    public virtual String getBatchDescription() {
        return null;
    }

    /**
     * Pre-setup for batch panel
     */
    public virtual String getRecommendedIntervalMode() {
        return INTERVAL_MINUTES;
    }

    /**
     * Pre-setup for batch panel
     */
    public virtual Integer getRecommendedRelaunchInterval() {
        return 10;
    }

    /**
     * Pre-setup for batch panel
     */
    public virtual Integer getRecommendedScopeSize() {
        return 200;
    }

    public virtual void finalAction() {
    }

    public virtual void finish(Database.BatchableContext param1) {
        finalAction();
        if(skipRelaunch !=true){
        List<Batch_Detail__c> batchDetails = [
            SELECT Interval_Mode__c, Relaunch_Interval__c, Scope_Size__c
            FROM Batch_Detail__c
            WHERE Name = :getType().getName()
        ];
        if (!batchDetails.isEmpty()) {
            Batch_Detail__c detail = batchDetails.get(0);
            Integer minutes = getMinutesByMode(
                detail.Interval_Mode__c,
                detail.Relaunch_Interval__c.intValue()
            );
            Integer scopeSize = detail.Scope_Size__c.intValue();
            System.debug('Next Scope Size: ' + scopeSize);
            System.scheduleBatch(
                (Database.Batchable<SObject>) getType().newInstance(),
                getType().getName(),
                minutes,
                scopeSize
            );
        }
        }else{
            //Skipped relaunch
        }
    }

    public static Integer getMinutesByMode(String intervalMode, Integer interval) {
        Integer minutes;
        switch on intervalMode {
            when 'Hours' {
                minutes = interval * 60;
            }
            when 'Days' {
                minutes = interval * 1440;
            }
            when 'Weeks' {
                minutes = interval * 10080;
            }
            when 'Months' {
                minutes = interval * 43800;
            }
            when else {
                minutes = interval;
            }
        }

        return minutes;
    }
}
