/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class PlatformEventService {

    public void remindEventFire() {
        Database.SaveResult result = EventBus.publish(new Reminder_Event__e());
    }
}