/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourceReminderRemote {

    @AuraEnabled
    public static List<ResourceReminderService.Reminder> getReminders(Id resId) {
        ResourceReminderService reminderService = (ResourceReminderService) ClassFactory.newInstance(ResourceReminderService.class);
        return  reminderService.getActiveReminders(resId);
    }
}