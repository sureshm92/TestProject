/**
 * Created by AlexKetch && Alexy Fisher on 3/3/2019.
 */

public virtual with sharing class TriggerHandler {
    private TriggerOperation currentTriggerEvent;
    private RunCounter counter;
    private DebugModeStats debugStats;
    private System.Type handlerType;
    //PUBLIC INTERFACE
    //before

    protected TriggerHandler(System.Type handlerType) {
        this.handlerType = handlerType;
        this.counter = new RunCounter(handlerType);
        this.debugStats = new DebugModeStats(handlerType);
    }
    protected TriggerHandler() {

    }
    public virtual void beforeInsert(List<SObject> newList) {
        this.setTriggerEvent(TriggerOperation.BEFORE_INSERT);
        this.debugStart();
        this.runBeforeHandle();
        this.onBeforeInsert(newList);
        this.runAfterHandle();
        this.debugFinish();
    }
    public void setHandlerType(System.Type handlerType) {
        this.handlerType = handlerType;
    }

    public virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.setTriggerEvent(TriggerOperation.BEFORE_UPDATE);
        this.debugStart();
        this.runBeforeHandle();
        this.onBeforeUpdate(newList, oldMap);
        this.runAfterHandle();
        this.debugFinish();
    }

    public virtual void beforeDelete(List<SObject> oldList) {
        this.setTriggerEvent(TriggerOperation.BEFORE_DELETE);
        this.runBeforeHandle();
        this.onBeforeDelete(oldList);
        this.runAfterHandle();
        this.debugFinish();
    }

    //after
    public virtual void afterInsert(List<SObject> newList) {
        this.setTriggerEvent(TriggerOperation.AFTER_INSERT);
        this.debugStart();
        this.runBeforeHandle();
        this.onAfterInsert(newList);
        this.runAfterHandle();
        this.debugFinish();
    }

    public virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.setTriggerEvent(TriggerOperation.AFTER_UPDATE);
        this.debugStart();
        this.runBeforeHandle();
        this.onAfterUpdate(newList, oldMap);
        this.runAfterHandle();
        this.debugFinish();
    }

    public virtual void afterDelete(List<SObject> oldList) {
        this.setTriggerEvent(TriggerOperation.AFTER_DELETE);
        this.debugStart();
        this.runBeforeHandle();
        this.onAfterDelete(oldList);
        this.runAfterHandle();
        this.debugFinish();
    }

    public virtual void afterUnDelete(List<SObject> oldList) {
        this.setTriggerEvent(TriggerOperation.AFTER_UNDELETE);
        this.debugStart();
        this.runBeforeHandle();
        this.onAfterUnDelete(oldList);
        this.runAfterHandle();
        this.debugFinish();
    }


    //OVERRIDE
    protected virtual void onBeforeInsert(List<SObject> newList) {
    }

    protected virtual void onBeforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

    }

    protected virtual void onBeforeDelete(List<SObject> oldList) {
    }

    //after
    protected virtual void onAfterInsert(List<SObject> newList) {
    }

    protected virtual void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
    }

    protected virtual void onAfterDelete(List<SObject> oldList) {
    }

    protected virtual void onAfterUnDelete(List<SObject> oldList) {
    }

    protected virtual void runBeforeHandle() {

    }

    protected virtual void runAfterHandle() {

    }
    //private methods

    private void debugStart() {
        if (TriggerHandlerExecutor.isDebugMode()) {
            this.getCounter().run(this.currentTriggerEvent);
            this.getDebugStatus().logStart();
        }
    }
    private void debugFinish() {
        if (TriggerHandlerExecutor.isDebugMode()) {
            this.getDebugStatus().logFinish();
            this.getDebugStatus().previewStats(this.currentTriggerEvent);
            this.getCounter().runPreview(this.currentTriggerEvent);
        }

    }
    private RunCounter getCounter() {
        if (this.counter == null) {
            this.counter = new RunCounter(this.handlerType);
        }
        return this.counter;
    }
    private DebugModeStats getDebugStatus() {
        if (this.debugStats == null) {
            this.debugStats = new DebugModeStats(this.handlerType);
        }
        return this.debugStats;
    }
    private class RunCounter {

        private Map<TriggerOperation, Integer> runCount;
        private System.Type handlerType;

        public RunCounter(System.Type handlerType) {
            this.runCount = new Map<TriggerOperation, Integer>{
                    TriggerOperation.BEFORE_INSERT => 0,
                    TriggerOperation.BEFORE_UPDATE => 0,
                    TriggerOperation.BEFORE_DELETE => 0,
                    TriggerOperation.AFTER_INSERT => 0,
                    TriggerOperation.AFTER_UPDATE => 0,
                    TriggerOperation.AFTER_DELETE => 0,
                    TriggerOperation.AFTER_UNDELETE => 0
            };
            this.handlerType = handlerType;
        }

        public void run(TriggerOperation event) {
            this.runCount.put(event, this.runCount.get(event) + 1);

            System.debug('>> ' + this.handlerType.getName() + ' executing ' + event);
        }

        public void runPreview(TriggerOperation event) {
            System.debug('\n>> ' + this.handlerType.getName() + ':' + event + ' finished.\nTotals: ' + this.runCount);
        }
    }

    private void setTriggerEvent(TriggerOperation event) {
        this.currentTriggerEvent = event;
    }

    private class DebugModeStats {

        private System.Type handlerType;
        private Map<String, Decimal> statsBefore;
        private Map<String, Decimal> statsAfter;

        public DebugModeStats(System.Type handlerType) {
            this.handlerType = handlerType;
            this.statsBefore = new Map<String, Decimal>();
            this.statsAfter = new Map<String, Decimal>();
        }

        public void logStart() {
            this.statsBefore.put('Queries', Limits.getQueries());
            this.statsBefore.put('Query rows', Limits.getQueryRows());
            this.statsBefore.put('Dml statements', Limits.getDmlStatements());
            this.statsBefore.put('Dml rows', Limits.getDmlRows());
        }

        public void logFinish() {
            this.statsAfter.put('Queries', Limits.getQueries());
            this.statsAfter.put('Query rows', Limits.getQueryRows());
            this.statsAfter.put('Dml statements', Limits.getDmlStatements());
            this.statsAfter.put('Dml rows', Limits.getDmlRows());
        }

        public void previewStats(TriggerOperation event) {
            System.debug('\n?> Stats for ' + this.handlerType.getName() + ':' + event);
            for (String key : this.statsBefore.keySet()) {
                System.debug(key + ' used ' + (this.statsAfter.get(key) - this.statsBefore.get(key)));
            }
        }
    }
    //utility


}