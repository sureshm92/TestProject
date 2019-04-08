/**
 * Created by Igor Malyuta on 04.04.2019.
 */

public with sharing class Batch_ReviewOnboardingFAQ implements Database.Batchable<SObject> {

    public static final String QUERY = 'SELECT Id, userCommunity_ShowTour__c FROM Contact';

    public static final String SHOW_ALL = 'PI;HCP;Participant';
    public static final String SHOW_PI = 'PI';
    public static final String SHOW_HCP = 'HCP';
    public static final String SHOW_PARTICIPANT = 'Participant';

    private String showMods;

    public Batch_ReviewOnboardingFAQ(String showMods) {
        this.showMods = showMods;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        for (Contact contact : contacts) {
            if(showMods.equals(SHOW_ALL)) {
                contact.userCommunity_ShowTour__c = SHOW_ALL;
            }else {
                String mods = contact.userCommunity_ShowTour__c != null ? contact.userCommunity_ShowTour__c : '';
                if (!mods.contains(showMods)) {
                    mods += ';' + showMods;
                }
                contact.userCommunity_ShowTour__c = mods;
            }
        }
        update contacts;
    }

    public void finish(Database.BatchableContext param1) {}

    public static void runAll() {
        Database.executeBatch(new Batch_ReviewOnboardingFAQ(SHOW_ALL));
    }

    public static void runPI() {
        Database.executeBatch(new Batch_ReviewOnboardingFAQ(SHOW_PI));
    }

    public static void runHCP() {
        Database.executeBatch(new Batch_ReviewOnboardingFAQ(SHOW_HCP));
    }

    public static void runParticipant() {
        Database.executeBatch(new Batch_ReviewOnboardingFAQ(SHOW_PARTICIPANT));
    }
}