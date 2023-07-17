/**
 * Created by Leonid Bartenev
 */

public without sharing class HomePageParticipantRemote {
    private static void initialUpdate() {
        List<User> users = [
            SELECT ContactId, Contact.Next_Notify_Date__c, LastLoginDate
            FROM User
            WHERE Id = :UserInfo.getUserId() AND LastLoginDate != NULL
        ];

        if (!users.isEmpty()) {
            User user = users.get(0);
            if (user.Contact.Next_Notify_Date__c != Date.today()) {
                ContactService.updateNextNotifyDate(user.ContactId, user.LastLoginDate);
            }
        }
        ContactService.updateVisitedCommunity(
            UserContext.getUserContact(),
            UserContext.getCurrentCommunityTemplate()
        );
    }

    class peStateAndCount {
        @AuraEnabled
        public ParticipantService.ParticipantState pState;
        @AuraEnabled
        public Integer pvCount;
        @AuraEnabled
        public Boolean televisitVendorAvailable;
    }

    @AuraEnabled(cacheable=false)
    public static String getInitData() {
        try {
            initialUpdate();
            return JSON.serialize(ParticipantService.getInstance().getState());
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static String getInitDataAndCount() {
        try {
            initialUpdate();
            peStateAndCount peSAndC = new peStateAndCount();
            peSAndC.pState = ParticipantService.getInstance().getState();
            peSAndC.pvCount = 0;
            if (
                peSAndC.pState != null &&
                peSAndC.pState.pe != null &&
                peSAndC.pState.pe.Id != null
            ) {
                Integer count = 0;
                Id peId = peSAndC.pState.pe.Id;
                String countQuery = 'SELECT count() FROM Patient_Visit__c WHERE Participant_Enrollment__c =:peId';
                count = Database.countQuery(countQuery);
                peSAndC.pvCount = count;

                Participant_Enrollment__c pe = [
                    SELECT Id, Study_Site__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :peId
                    LIMIT 1
                ];
                List<TelevisitVendorSettings__c> tvs = new List<TelevisitVendorSettings__c>();
                tvs = [
                    SELECT Id, isEnable__c
                    FROM TelevisitVendorSettings__c
                    WHERE Study_Site__c = :pe.Study_Site__c
                    ORDER BY lastmodifieddate DESC
                    LIMIT 1
                ];
                if (tvs.size() > 0)
                    peSAndC.televisitVendorAvailable = tvs[0].isEnable__c;
            }
            return JSON.serialize(peSAndC);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Boolean getIsRTL() {
        try {
            return (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static String getPIDetails(String studySiteId) {
        Study_Site__c ss = [
            SELECT
                id,
                Principal_Investigator__c,
                Principal_Investigator__r.Salutation,
                Principal_Investigator__r.Name
            FROM Study_Site__c
            WHERE id = :studySiteId
        ];
        list<Participant__c> pp = [
            SELECT id, First_Name__c, Last_Name__c, Contact__c
            FROM Participant__c
            WHERE Contact__c = :ss.Principal_Investigator__c
        ];
        PIDetails PI;
        if (pp != null && pp.size() > 0) {
            PI = new PIDetails(pp[0].First_Name__c + ' ' + pp[0].Last_Name__c, '');
        } else {
            PI = new PIDetails(
                ss.Principal_Investigator__r.Name,
                ss.Principal_Investigator__r.Salutation
            );
        }
        return JSON.serialize(PI);
    }

    @AuraEnabled
    public static String getStudyStaff(String studySiteId) {
        List<Site_Staff__c> siteStaffList = new List<Site_Staff__c>();
        set<Id> setContactIds = new Set<Id>();
        Map<Id, Participant__c> mapContactIdToParticipant = new Map<Id, Participant__c>();
        siteStaffList = [
            SELECT
                Id,
                Name,
                Site_Contact__c,
                Site_Contact__r.Name,
                Study_Site__c,
                Site_Contact__r.Salutation,
                Delegate_Level__c
            FROM Site_Staff__c
            WHERE Study_Site__c = :studySiteId
            ORDER BY Delegate_Level__c ASC
        ];

        for (Site_Staff__c ss : siteStaffList) {
            setContactIds.add(ss.Site_Contact__c);
        }

        for (Participant__c pp : [
            SELECT id, First_Name__c, Last_Name__c, Contact__c
            FROM Participant__c
            WHERE Contact__c IN :setContactIds
        ]) {
            mapContactIdToParticipant.put(pp.Contact__c, pp);
        }

        String stringJson = JSON.serialize(siteStaffList);
        Object orderRecords = JSON.deserializeUntyped(stringJson);
        for (Object ob : (List<Object>) orderRecords) {
            Map<String, Object> obMap = (Map<String, Object>) ob;
            Map<String, Object> orderDetailsMap = (Map<String, Object>) obMap.get(
                'Site_Contact__r'
            );
            Id ContactId = (Id) orderDetailsMap.get('Id');
            if (mapContactIdToParticipant.containsKey(ContactId)) {
                Participant__c pp = mapContactIdToParticipant.get(ContactId);
                String Name = pp.First_Name__c + ' ' + pp.Last_Name__c;
                orderDetailsMap.put('Name', Name);
            }
        }

        return JSON.serialize(orderRecords);
    }

    class PIDetails {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Salutation;
        public PIDetails(String Name, String Salutation) {
            this.Name = Name;
            this.Salutation = Salutation;
        }
    }
}
