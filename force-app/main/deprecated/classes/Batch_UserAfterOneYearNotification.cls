/**
 * Created by Igor Malyuta on 11.03.2020.
 */
//DEPRECATED. ONLY FOR STUB
public without sharing class Batch_UserAfterOneYearNotification extends Batch_ScheduledAbstract {

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return new List<SObject>();
    }

    public void execute(Database.BatchableContext param1, List<Object> param2) {
    }

    public override Type getType() {
        return Batch_UserAfterOneYearNotification.class;
    }
}