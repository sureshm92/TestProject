/**
 * Created by Igor Malyuta on 04.04.2019.
 */

public with sharing class Batch_ReviewOnboardingFAQ implements Database.Batchable<SObject> {

    private static final String QUERY = 'SELECT Id, userCommunity_ShowTour__c FROM Contact';
    public static final String DEFAULT_FIELD_VALUE = 'PI;HCP;Participant';

    private String userModsToReset;

    public Batch_ReviewOnboardingFAQ(String userModsToReset) {
        this.userModsToReset = userModsToReset;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext param1, List<SObject> contacts) {
        if(contacts.get(0).getSObjectType() == Contact.getSObjectType()) {
            for(Contact contact : (List<Contact>) contacts) {
                String mods = contact.userCommunity_ShowTour__c;
                if (!mods.contains(userModsToReset)) {
                    mods += ';' + userModsToReset;
                }
            }

            update contacts;
        }
    }

    public void finish(Database.BatchableContext param1) {}

    public static void run(String userModsToReset) {
        Database.executeBatch(new Batch_ReviewOnboardingFAQ(userModsToReset), 100);
    }
}