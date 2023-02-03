/**
* Created by D.Yasinskyi on 05.05.2018
* Refactored by Leonid Bartenev
*/

public without sharing class ContactTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------
    //public static Boolean noUpdateOnParticipantRecord = false;
    public class UpdateParticipantAndUserEmailsOnEmailChangeHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateParticipantAndUserEmailsOnEmailChange(newList, (Map<Id, Contact>) oldMap);
        }
    }
    
    public class CreateUserForDelegateContactHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createUserForDelegateContact(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createUserForDelegateContact(newList);
        }
    }
    
    public class UpdatePhoneNumberContactsHandler extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createTaskToUpdatePhoneNumber(newList, (Map<Id, Contact>) oldMap);
        }
    }
    /*For Welcome Msg -- Added by Anitha Start*/
    public class createNotificationsHandler extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            retryWelcomeMsg(newList, (Map<Id, Contact>) oldMap);
            createNotificationforWelcomemsg(newList, (Map<Id, Contact>) oldMap);
        }
    }
    
    public class SetShowTourDefaultHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setShowTourDefault(newList);
        }
    }
    
    public class PopulateOverrideFields extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            populateOverrideFields(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            populateOverrideFields(newList);
        }
    }
    
    public class CreateUserForCCContactHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createUserForCCContact(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (!Test.isrunningTest()) {
                createUserForCCContact(newList);
            }
        }
    }
    
    public class UpdateParticipantDetailsHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateParticipantDetailsHandler((List<Contact>) newList, (Map<Id, Contact>) oldMap);
        }
    }
    
    public class UpdateConsentTimeStamps extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateConsentTimeStamps((List<Contact>) newList);
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateConsentTimeStamps((List<Contact>) newList, (Map<Id, Contact>) oldMap);
        }
    }
    //updateParticipantConsent
    public class ParticipantConsentUpdate extends TriggerHandler {
        Boolean isPortalUser = ParticipantEnrollmentTriggerHandler.checkCurrentusrProfile();
        public override void beforeInsert(List<SObject> newList) {
            if (isPortalUser) {
                updateParticipantConsent((List<Contact>) newList, null);
            }
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (isPortalUser) {
                updateParticipantConsent((List<Contact>) newList, (Map<Id, Contact>) oldMap);
            }
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void updateParticipantDetailsHandler(
        List<Contact> newList,
        Map<Id, Contact> oldMap
    ) {
        Map<ID, Contact> updatedContactsMap = new Map<Id, Contact>();
        Map<Id, Contact> updatedContactsForNameMap = new Map<Id, Contact>();
        for (Contact c : newList) {
            Boolean isUpdateNeeded = false;
            Boolean isUpdateNameNeeded = false;
            if (c.MailingCountry != oldMap.get(c.Id).MailingCountry) {
                isUpdateNeeded = true;
            }
            if (c.MailingCountryCode != oldMap.get(c.Id).MailingCountryCode) {
                isUpdateNeeded = true;
            }
            if (c.MailingState != oldMap.get(c.Id).MailingState) {
                isUpdateNeeded = true;
            }
            if (c.MailingStateCode != oldMap.get(c.Id).MailingStateCode) {
                isUpdateNeeded = true;
            }
            if (c.MailingPostalCode != oldMap.get(c.Id).MailingPostalCode) {
                isUpdateNeeded = true;
            }
            if (c.Language__c != oldMap.get(c.Id).Language__c) {
                isUpdateNeeded = true;
            }
            if (c.Phone != oldMap.get(c.Id).Phone) {
                isUpdateNeeded = true;
            }
            if (c.FirstName != oldMap.get(c.Id).FirstName) {
                isUpdateNameNeeded = true;
            }
            if (c.LastName != oldMap.get(c.Id).LastName) {
                isUpdateNameNeeded = true;
            }
            if (isUpdateNeeded) {
                updatedContactsMap.put(c.Id, c);
            }
            if (isUpdateNameNeeded) {
                updatedContactsForNameMap.put(c.Id, c);
            }
        }
        if (updatedContactsMap.size() > 0 || updatedContactsForNameMap.size() > 0) {
            List<Participant__c> participantsToUpdate = new List<Participant__c>();
            for (Participant__c participant : [
                SELECT
                Id,
                Contact__c,
                Mailing_Country_Code__c,
                Preferred_Language__c,
                Phone__c,
                Mailing_State_Code__c,
                Mailing_Zip_Postal_Code__c
                FROM Participant__c
                WHERE
                Contact__c IN :updatedContactsMap.keySet()
                OR Contact__c IN :updatedContactsForNameMap.keySet()
            ]) {
                Boolean isUpdateNeeded = false;
                if (updatedContactsMap.containsKey(participant.Contact__c)) {
                    if (
                        participant.Mailing_Country_Code__c !=
                        updatedContactsMap.get(participant.Contact__c).MailingCountryCode
                    ) {
                        participant.Mailing_Country_Code__c = updatedContactsMap.get(
                            participant.Contact__c
                        )
                            .MailingCountryCode;
                        isUpdateNeeded = true;
                    }
                    if (
                        participant.Mailing_State_Code__c !=
                        updatedContactsMap.get(participant.Contact__c).MailingStateCode
                    ) {
                        participant.Mailing_State_Code__c = updatedContactsMap.get(
                            participant.Contact__c
                        )
                            .MailingStateCode;
                        isUpdateNeeded = true;
                    }
                    if (
                        participant.Mailing_Zip_Postal_Code__c !=
                        updatedContactsMap.get(participant.Contact__c).MailingPostalCode
                    ) {
                        participant.Mailing_Zip_Postal_Code__c = updatedContactsMap.get(
                            participant.Contact__c
                        )
                            .MailingPostalCode;
                        isUpdateNeeded = true;
                    }
                    if (
                        participant.Preferred_Language__c !=
                        updatedContactsMap.get(participant.Contact__c).Language__c
                    ) {
                        participant.Preferred_Language__c = updatedContactsMap.get(
                            participant.Contact__c
                        )
                            .Language__c;
                        isUpdateNeeded = true;
                    }
                    if (
                        participant.Phone__c != updatedContactsMap.get(participant.Contact__c).Phone
                    ) {
                        participant.Phone__c = updatedContactsMap.get(participant.Contact__c).Phone;
                        isUpdateNeeded = true;
                    }
                }
                if (isUpdateNeeded) {
                    participantsToUpdate.add(participant);
                    system.debug('*****participantsToUpdate: ' + participantsToUpdate);
                }
                if (updatedContactsForNameMap.containsKey(participant.Contact__c)) {
                    updatedContactsForNameMap.remove(participant.Contact__c);
                }
            }
            if (participantsToUpdate.size() > 0) {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
                );
                update participantsToUpdate;
            }
        }
        if (!updatedContactsForNameMap.isEmpty()) {
            List<User> usersToUpdate = new List<User>();
            for (User u : [
                SELECT Id, ContactId, FirstName, LastName
                FROM User
                WHERE ContactId IN :updatedContactsForNameMap.keySet()
            ]) {
                Boolean isUpdateNeeded = false;
                if (u.FirstName != updatedContactsForNameMap.get(u.ContactId).FirstName) {
                    u.FirstName = updatedContactsForNameMap.get(u.ContactId).FirstName;
                    isUpdateNeeded = true;
                }
                if (u.LastName != updatedContactsForNameMap.get(u.ContactId).LastName) {
                    u.LastName = updatedContactsForNameMap.get(u.ContactId).LastName;
                    isUpdateNeeded = true;
                }
                if (isUpdateNeeded) {
                    usersToUpdate.add(u);
                }
            }
            if (!usersToUpdate.isEmpty()) {
                update usersToUpdate;
            }
        }
    }
    
    @TestVisible
    private static void updateParticipantAndUserEmailsOnEmailChange(
        List<Contact> newList,
        Map<Id, Contact> oldMap
    ) {
        Boolean needUpdate = false;
        for (Contact cnt : newList) {
            needUpdate = ((oldMap.get(cnt.Id).Email != cnt.Email) ||
                          (oldMap.get(cnt.Id).Language__c != cnt.Language__c));
            if (needUpdate)
                break;
        }
        if (needUpdate) {
            //prepare participants map:
            List<Participant__c> participants = [
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Contact__c IN :newList
            ];
            Map<Id, Participant__c> participantsByContactMap = new Map<Id, Participant__c>();
            for (Participant__c participant : participants)
                participantsByContactMap.put(participant.Contact__c, participant);
            //prepare users map:
            List<User> users = [
                SELECT Id, Email, LanguageLocaleKey, ContactId
                FROM User
                WHERE ContactId IN :newList
            ];
            Map<Id, User> usersByContactMap = new Map<Id, User>();
            for (User user : users)
                usersByContactMap.put(user.ContactId, user);
            //process contacts:
            List<Participant__c> participantsForUpdate = new List<Participant__c>();
            List<User> usersForUpdate = new List<User>();
            for (Contact cnt : newList) {
                Contact oldCnt = oldMap.get(cnt.Id);
                if ((oldCnt.Email != cnt.Email) || (oldCnt.Language__c != cnt.Language__c)) {
                    Participant__c participant = participantsByContactMap.get(cnt.Id);
                    if (participant != null) {
                        participant.Email__c = cnt.Email;
                        //participant.Preferred_Language__c = cnt.Language__c;
                        participantsForUpdate.add(participant);
                    }
                    User user = usersByContactMap.get(cnt.Id);
                    Boolean isUpdateNeeded = false;
                    if (user != null) {
                        if (user.Email != cnt.Email) {
                            user.Email = cnt.Email;
                            isUpdateNeeded = true;
                        }
                        if (user.LanguageLocaleKey != cnt.Language__c) {
                            user.LanguageLocaleKey = cnt.Language__c;
                            isUpdateNeeded = true;
                        }
                        if (isUpdateNeeded) {
                            usersForUpdate.add(user);
                        }
                    }
                }
            }
            if (!usersForUpdate.isEmpty()) {
                update usersForUpdate;
            }
            if (!participantsForUpdate.isEmpty()) {
                update participantsForUpdate;
            }
        }
    }
    
    @TestVisible
    private static void createUserForDelegateContact(List<Contact> newList) {
        Map<Id, Contact> filteredContactsByIds = new Map<Id, Contact>();
        
        for (Contact cont : newList) {
            if (cont.Email != null && cont.primaryContact__c != null) {
                filteredContactsByIds.put(cont.Id, cont);
            }
        }
        if (filteredContactsByIds.isEmpty())
            return;
        
        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (
            User usr : CommunityService.getCommunityUsersByContactIds(
                filteredContactsByIds.keySet()
            )
        ) {
            if (communityUsers.containsKey(usr.ContactId)) {
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId))
                toCreateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
            .createPortalUsers(toCreateUser);
    }
    
    @TestVisible
    private static void setShowTourDefault(List<Contact> newList) {
        List<String> defaultModes = new List<String>{
            CommunityService.USER_MODE_PI,
                CommunityService.USER_MODE_HCP,
                CommunityService.USER_MODE_PARTICIPANT
                };
                    for (Contact contact : newList)
                    contact.userCommunity_ShowTour__c = String.join(defaultModes, ';');
    }
    
    private static void populateOverrideFields(List<Contact> newList) {
        for (Contact contact : newList) {
            if (contact.LastName != null && String.isBlank(contact.Override_Mailing_Address__c)) {
                //MailingStreet & BR() & MailingCity & ", " & MailingState & " " &MailingPostalCode
                contact.Override_Mailing_Address__c =
                    contact.MailingStreet +
                    '\n' +
                    contact.MailingCity +
                    ', ' +
                    contact.MailingState +
                    ' ' +
                    contact.MailingPostalCode;
            }
            if (contact.LastName != null && String.isBlank(contact.Override_Phone__c)) {
                contact.Override_Phone__c = contact.Phone;
            }
            if (contact.userCommunityMode__c == 'CC') {
                contact.userCommunytyType__c = 'CC';
            }
            contact.Next_Profile_Update_DT__c = Datetime.now().addYears(1);
        }
    }
    
    @TestVisible
    private static void createUserForCCContact(List<Contact> newList) {
        Map<Id, Contact> filteredCCContactsByIds = new Map<Id, Contact>();
        List<Id> DeactivateCCContact = new List<Id>();
        
        for (Contact cont : newList) {
            if (cont.userCommunityMode__c == 'CC') {
                if (cont.Email != null && cont.CC_Staff_Status__c) {
                    filteredCCContactsByIds.put(cont.Id, cont);
                }
                if (!cont.CC_Staff_Status__c) {
                    DeactivateCCContact.add(cont.Id);
                }
            }
        }
        if (!DeactivateCCContact.isEmpty())
            CommunityService.deactivateUsers(DeactivateCCContact);
        
        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (
            User usr : CommunityService.getCommunityUsersByContactIds(
                filteredCCContactsByIds.keySet()
            )
        ) {
            if (communityUsers.containsKey(usr.ContactId)) {
                System.debug('Several users for contact Id= ' + usr.Id);
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }
        
        Set<Id> toActivateUser = new Set<Id>();
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredCCContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId))
                toCreateUser.add(contactId);
            else
                toActivateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
            .createCCPortalUsers(toCreateUser);
        
        if (!toActivateUser.isEmpty())
            CommunityService.ActivateUsers(toActivateUser);
    }
    
    @TestVisible
    private static List<Notification__c> platformLevelNotifications(
        Set<ID> conlst,
        Map<Id, Contact> oldMap,
        List<Contact> newList,
        String operationtype
    ) {
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Map<Id, Participant__c> participantcontact = new Map<Id, Participant__c>();
        List<ID> participantids = new List<ID>();
        Map<Id, List<Id>> partPerDelegateIds = new Map<Id, List<Id>>();
        Map<Id, Participant__c> participantconMap;
        Map<Id, Participant__c> particpantmap = new Map<Id, Participant__c>(
            [SELECT Id, Contact__c, Adult__c FROM Participant__c WHERE Contact__c IN :conlst]
        );
        system.debug('particpantmap:::' + particpantmap);
        if (!particpantmap.isEmpty()) {
            for (Participant__c participant : particpantmap.values()) {
                participantcontact.put(participant.Contact__c, participant);
                participantids.add(participant.Id);
                system.debug('participantcontact:::' + participantcontact);
            }
            if (participantids.size() > 0) {
                List<Id> perIdList = new List<Id>();
                PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
                    participantIds,perIdList
                );
                partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs
                
                system.debug('partPerDelegateIds:::' + partPerDelegateIds);
            }
        }
        for (Contact con : newList) {
            if (participantcontact.containskey(con.Id)) {
                if (operationtype == 'Mobile') {
                    system.debug('platform level contact');
                    if (
                        particpantmap.get(participantcontact.get(con.Id).Id).Adult__c &&
                        con.Participant_Opt_In_Status_SMS__c &&
                        !con.Welcome_Message_Sent__c &&
                        !con.Welcome_Message_Delivered__c
                    ) {
                        if (con.UserCommunityIsDelegate__c == false) {
                            // Means he is only purely a participant - not a delegate of another participant - Sent Platfomr level SMS for Participant
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    con.Id,
                                    participantcontact.get(con.Id).Id,
                                    NotificationCatalog.MSG_TO_PT_PLATFORM_LVL_WELCME_MSG,
                                    false
                                )
                            );
                        } else if (con.UserCommunityIsDelegate__c == true) {
                            //if(partPerDelegateIds != null && partPerDelegateIds.contains(participantcontact.get(con.Id))){ // If condition is not required due to paltform Level
                            //Menans contact is having delegate role, if yes, Send Platform Level SMS to the Same contact for Delegate Type.
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    con.Id,
                                    participantcontact.get(con.Id).Id,
                                    NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                    true
                                )
                            );
                        }
                    }
                    // }
                    if (!partPerDelegateIds.isEmpty()) {
                        for (
                            Id delegateconId : partPerDelegateIds.get(
                                participantcontact.get(con.Id).Id
                            )
                        ) {
                            /*Platform Level Delegate*/
                            system.debug('platform level del contact');
                            // Adding for adult
                            //if(participantconMap.containskey(participantcontact.get(con.Id).Id) && participantconMap.get(participantcontact.get(con.Id).Id).Adult__c){
                            Boolean isDelegateretryNotification =
                                ContactService.patientdelList.containskey(delegateconId) &&
                                ContactService.patientdelList.get(delegateconId)
                                .Contact__r.Participant_Opt_In_Status_SMS__c &&
                                !(ContactService.patientdelList.get(delegateconId)
                                  .Contact__r.Welcome_Message_Sent__c) &&
                                !(ContactService.patientdelList.get(delegateconId)
                                  .Contact__r.Welcome_Message_Delivered__c);
                            if (isDelegateretryNotification) {
                                welcomemsgnotifications.addAll(
                                    ContactService.addwelcomeNotifications(
                                        delegateconId,
                                        participantcontact.get(con.Id).Id,
                                        NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                        true
                                    )
                                );
                            }
                            /*}*/
                        }
                    }
                } else if (operationtype == 'smsoptin') {
                    /*Platform Level PT mEsg*/
                    if (!con.Welcome_Message_Sent__c && con.Participant_Opt_In_Status_SMS__c) {
                        if (particpantmap.get(participantcontact.get(con.Id).Id).Adult__c) {
                            if (con.UserCommunityIsDelegate__c == false) {
                                // Means he is only purely a participant - not a delegate of another participant - Sent Platfomr level SMS for Participant
                                welcomemsgnotifications.addAll(
                                    ContactService.addwelcomeNotifications(
                                        con.Id,
                                        participantcontact.get(con.Id).Id,
                                        NotificationCatalog.MSG_TO_PT_PLATFORM_LVL_WELCME_MSG,
                                        false
                                    )
                                );
                            } else if (con.UserCommunityIsDelegate__c == true) {
                                //if(partPerDelegateIds != null && partPerDelegateIds.contains(participantcontact.get(con.Id))){
                                //Menans contact is having delegate role, if yes, Send Platform Level SMS to the Same contact for Delegate Type.
                                // If condition is not required due to paltform lEvel
                                welcomemsgnotifications.addAll(
                                    ContactService.addwelcomeNotifications(
                                        con.Id,
                                        participantcontact.get(con.Id).Id,
                                        NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                        true
                                    )
                                );
                            }
                        }
                    }
                    //}
                    if (!partPerDelegateIds.isEmpty()) {
                        for (
                            Id delegateconId : partPerDelegateIds.get(
                                participantcontact.get(con.Id).Id
                            )
                        ) {
                            Boolean isDelegateOptInNotification =
                                ContactService.patientdelList.containskey(delegateconId) &&
                                ContactService.patientdelList.get(delegateconId)
                                .Contact__r.Participant_Opt_In_Status_SMS__c &&
                                !(ContactService.patientdelList.get(delegateconId)
                                  .Contact__r.Welcome_Message_Sent__c);
                            if (isDelegateOptInNotification) {
                                /*Platform Level Delegate*/
                                welcomemsgnotifications.addAll(
                                    ContactService.addwelcomeNotifications(
                                        delegateconId,
                                        participantcontact.get(con.Id).Id,
                                        NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                        true
                                    )
                                );
                            }
                        }
                    }
                }
            }
        }
        return welcomemsgnotifications;
    }
    
    @TestVisible
    //This method is used When the sms consent goes from off to on send welcome message at contact
    private static void createNotificationforWelcomemsg(
        List<Contact> newList,
        Map<Id, Contact> oldMap
    ) {
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Set<ID> booleanupdateconidslst = new Set<ID>();
        for (Contact con : newList) {
            if (
                oldMap != null &&
                con.Participant_Opt_In_Status_SMS__c !=
                oldMap.get(con.Id).Participant_Opt_In_Status_SMS__c &&
                !con.Participant_Opt_In_Status_SMS__c
            ) {
                con.Welcome_Message_Sent__c = false;
                con.Welcome_Message_Delivered__c = false;
            } else if (
                oldMap != null &&
                !con.Welcome_Message_Sent__c &&
                ((con.Participant_Opt_In_Status_SMS__c !=
                  oldMap.get(con.Id).Participant_Opt_In_Status_SMS__c &&
                  con.Participant_Opt_In_Status_SMS__c))
            ) {
                booleanupdateconidslst.add(con.Id);
            }
        }
        /*Sending Platform Level SMS for Participant_Opt_In_Status_SMS__c update*/
        if (booleanupdateconidslst.size() > 0) {
            system.debug('contact platform');
            welcomemsgnotifications.addAll(
                platformLevelNotifications(booleanupdateconidslst, oldMap, newList, 'smsoptin')
            );
        }
        if (!welcomemsgnotifications.isEmpty())
            insert welcomemsgnotifications;
    }
    @TestVisible
    //This method is to retry the welcome msg whenever is_Invalid_number__c field is true  and Mobile no is updated at contact
    private static void retryWelcomeMsg(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<ID> mbleupdateconidslst = new Set<ID>();
        Set<ID> deleConIdSet = new Set<ID>();
        Map<Id, Contact> contMapForStatusUpdate = new Map<Id, Contact>();
        List<ID> participantids = new List<ID>();
        List<Id> perIdlst = new List<Id>();
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Map<Id, List<Id>> partPerDelegateIds = new Map<Id, List<Id>>();
        List<Task> taskForUpdatePhoneNumber = new List<Task>();
        
        for (contact cont : newList) {
            if (cont.is_Invalid_number__c && cont.MobilePhone != oldMap.get(cont.Id).MobilePhone) {
                contMapForStatusUpdate.put(cont.Id, cont);
                // For purely participant
                if (!cont.UserCommunityIsDelegate__c) {
                    mbleupdateconidslst.add(cont.Id);
                } else {
                    deleConIdSet.add(cont.Id);
                }
                cont.Is_Invalid_Number__c = false;
            }
        }
        if (mbleupdateconidslst.size() > 0) {
            /*Sending Study level and Platform Level SMS for Mobile no update*/
            Map<Id, Participant_Enrollment__c> peIdMap = new Map<Id, Participant_Enrollment__c>(
                [
                    SELECT
                    Id,
                    Participant_Contact__c,
                    Welcome_Message_Delivered__c,
                    Participant__c,
                    Welcome_Message_Sent__c,
                    Participant__r.Adult__c
                    FROM Participant_Enrollment__c
                    WHERE Participant_Contact__c IN :mbleupdateconidslst
                ]
            );
            if (!peIdMap.isEmpty()) {
                for (Participant_Enrollment__c per : peIdMap.values()) {
                    participantIds.add(per.Participant__c);
                    perIdlst.add(per.Id);
                }
                if (participantids.size() > 0 && perIdlst.size()>0) {
                    /*partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
participantIds
);*/
                    String fieldFilter = 'Patient_Delegate__r.Participant__c';
                    PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
                        participantIds,perIdlst
                    );
                    partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs
                    
                }
                for (Participant_Enrollment__c per : peIdMap.values()) {
                    if (!per.Welcome_Message_Sent__c && !per.Welcome_Message_Delivered__c) {
                        if (!String.isBlank(per.Participant__c) && per.Participant__r.Adult__c) {
                            /*Study Level Welcome Msg to PT*/
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    per.Participant_Contact__c,
                                    per.Id,
                                    NotificationCatalog.MESSAGE_TO_PT_STUDY_LEVEL_WELCOME_MSG,
                                    false
                                )
                            );
                        }
                        if (partPerDelegateIds.containsKey(per.Participant__c)) {
                            for (Id delegateconId : partPerDelegateIds.get(per.Participant__c)) {
                                /*Study Level Delegate*/
                                welcomemsgnotifications.addAll(
                                    ContactService.addwelcomeNotifications(
                                        delegateconId,
                                        per.Id,
                                        NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                                        true
                                    )
                                );
                            }
                        }
                    }
                }
            }
        }
        if (deleConIdSet.size() > 0) {
            /*Sending Study level SMS to delegate for Mobile no update*/
            Map<Id, Patient_Delegate_Enrollment__c> perJunctionIdMap = new Map<Id, Patient_Delegate_Enrollment__c>(
                [
                    SELECT
                    Id,
                    Participant_Enrollment__c,
                    Welcome_Message_Sent__c,
                    Welcome_Message_Delivered__c,
                    Patient_Delegate__c,
                    Patient_Delegate__r.Contact__c,
                    Patient_Delegate__r.Participant__c,
                    Name,
                    Status__c,
                    Participant_Enrollment__r.study__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE 
                    Patient_Delegate__r.Contact__c IN :deleConIdSet AND Status__c = 'Active'
                    AND Welcome_Message_Sent__c = FALSE
                    AND Welcome_Message_Delivered__c = FALSE
                ]
            );
            if (!perJunctionIdMap.isEmpty()) {
                for (Patient_Delegate_Enrollment__c per : perJunctionIdMap.values()) {
                    /*Study Level Welcome Msg to Delegate*/
                    welcomemsgnotifications.addAll(
                        ContactService.addwelcomeNotifications(
                            per.Patient_Delegate__r.Contact__c,
                            per.Participant_Enrollment__c,
                            NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                            true
                        )
                    );
                }
            }
        }
        if (mbleupdateconidslst.size() > 0 || deleConIdSet.size() > 0) {
            /*Send Platform Level Msg*/
            welcomemsgnotifications.addAll(
                platformLevelNotifications(mbleupdateconidslst, oldMap, newList, 'Mobile')
            );
        }
        if (contMapForStatusUpdate != null && !contMapForStatusUpdate.isEmpty()) {
            list<task> taskList = [
                SELECT Id, WhoId, Status
                FROM task
                WHERE
                WhoId IN :contMapForStatusUpdate.keySet()
                AND subject = :TaskService.TASK_CODE_UPDATE_YOUR_PHONE_NUMBER
                AND status = 'Open'
            ];
            for (task tl : taskList) {
                tl.Status = TaskService.TASK_STATUS_COMPLETED;
                tl.Completed_Date__c = Datetime.now();
                taskForUpdatePhoneNumber.add(tl);
            }
        }
        update taskForUpdatePhoneNumber;
        if (!welcomemsgnotifications.isEmpty())
            insert welcomemsgnotifications;
    }
    @TestVisible
    //This method creates a task to update phone number whenever is_Invalid_number__c field is updated to true at contact
    private static void createTaskToUpdatePhoneNumber(
        List<Contact> newList,
        Map<Id, Contact> oldMap
    ) {
        Map<Id, Contact> contMap = new Map<Id, Contact>();
        Map<Id, Contact> contMapForStatusUpdate = new Map<Id, Contact>();
        Map<Id, Id> contIdUserIdMap = new Map<Id, Id>();
        Map<Id, Id> contIdParMap = new Map<Id, Id>();
        List<Task> taskForUpdatePhoneNumber = new List<Task>();
        for (contact cont : newList) {
            //check if is_Invalid_number__c field is updated to true
            if (
                cont.is_Invalid_number__c &&
                cont.is_Invalid_number__c != oldMap.get(cont.Id).is_Invalid_number__c
            ) {
                contMap.put(cont.Id, cont);
            }
        }
        if (contMap != null && !contMap.isEmpty()) {
            //get the user from the contact list
            list<user> userList = [
                SELECT Id, contactId
                FROM user
                WHERE contactId IN :contMap.keySet()
            ];
            for (user u : userList) {
                contIdUserIdMap.put(u.contactId, u.Id);
            }
            //get the participant from the contact set
            list<participant__c> participantList = [
                SELECT Id, Contact__c
                FROM participant__c
                WHERE Contact__c IN :contMap.keySet()
            ];
            for (participant__c par : participantList) {
                contIdParMap.put(par.Contact__c, par.Id);
            }
            // call task service to create task to update phone number
            for (contact con : contMap.values()) {
                Id userId = contIdUserIdMap.get(con.Id);
                Id parId = contIdParMap.get(con.Id);
                if (parId != null) {
                    taskForUpdatePhoneNumber.add(
                        TaskService.getInstance().updateYourPhoneNumberTask(userId, parId, Con.Id)
                    );
                }
            }
        }
        insert taskForUpdatePhoneNumber;
    }
    
    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Contact> newList) {
        for (Contact con : newList) {
            if(!con.IQVIA_Contact_info_storage_consent__c){
                con.IQVIA_Contact_info_storage_consent__c = (con.Participant_Opt_In_Status_SMS__c || con.IQVIA_Pre_recorded_Voice_Consent__c ||
                                                             con.Participant_Phone_Opt_In_Permit_Phone__c || con.Participant_Opt_In_Status_Emails__c || con.IQVIA_Direct_Mail_Consent__c ||
                                                             con.IQVIA_Assisted_Dialing_Consent__c || con.IQVIA_Artificial_Voice_Consent__c );
            }
            con.IQVIA_SMS_Consent_Time__c = (con.Participant_Opt_In_Status_SMS__c
                                             ? Datetime.now()
                                             : null);
            con.IQVIA_Pre_recorded_Calls_Consent_Time__c = (con.IQVIA_Pre_recorded_Voice_Consent__c
                                                            ? Datetime.now()
                                                            : null);
            con.IQVIA_PI_Storage_Consent_Time__c = (con.IQVIA_Contact_info_storage_consent__c
                                                    ? Datetime.now()
                                                    : null);
            con.IQVIA_Phone_Consent_Time__c = (con.Participant_Phone_Opt_In_Permit_Phone__c
                                               ? Datetime.now()
                                               : null);
            con.IQVIA_Email_Consent_Time__c = (con.Participant_Opt_In_Status_Emails__c
                                               ? Datetime.now()
                                               : null);
            con.IQVIA_Direct_Mail_Consent_Time__c = (con.IQVIA_Direct_Mail_Consent__c
                                                     ? Datetime.now()
                                                     : null);
            con.IQVIA_Assisted_Dialing_Consent_Time__c = (con.IQVIA_Assisted_Dialing_Consent__c
                                                          ? Datetime.now()
                                                          : null);
            con.IQVIA_Artificial_Voice_Consent_Time__c = (con.IQVIA_Artificial_Voice_Consent__c
                                                          ? Datetime.now()
                                                          : null);
        }
    }
    
    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Contact> newList, Map<Id, Contact> oldMap) {
        for (Contact con : newList) {
            contact oldContact = oldMap.get(con.Id);
            
            if(!oldContact.IQVIA_Contact_info_storage_consent__c){
                con.IQVIA_Contact_info_storage_consent__c = (con.Participant_Opt_In_Status_SMS__c || con.IQVIA_Pre_recorded_Voice_Consent__c ||
                                                             con.Participant_Phone_Opt_In_Permit_Phone__c || con.Participant_Opt_In_Status_Emails__c || con.IQVIA_Direct_Mail_Consent__c ||
                                                             con.IQVIA_Assisted_Dialing_Consent__c || con.IQVIA_Artificial_Voice_Consent__c );
            }
            
            if (
                con.Participant_Opt_In_Status_SMS__c != oldContact.Participant_Opt_In_Status_SMS__c
            ) {
                con.IQVIA_SMS_Consent_Time__c = Datetime.now();
            }
            if (
                con.IQVIA_Pre_recorded_Voice_Consent__c !=
                oldContact.IQVIA_Pre_recorded_Voice_Consent__c
            ) {
                con.IQVIA_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
            }
            if (
                con.IQVIA_Contact_info_storage_consent__c !=
                oldContact.IQVIA_Contact_info_storage_consent__c
            ) {
                con.IQVIA_PI_Storage_Consent_Time__c = Datetime.now();
            }
            if (
                con.Participant_Phone_Opt_In_Permit_Phone__c !=
                oldContact.Participant_Phone_Opt_In_Permit_Phone__c
            ) {
                con.IQVIA_Phone_Consent_Time__c = Datetime.now();
            }
            if (
                con.Participant_Opt_In_Status_Emails__c !=
                oldContact.Participant_Opt_In_Status_Emails__c
            ) {
                con.IQVIA_Email_Consent_Time__c = Datetime.now();
            }
            if (con.IQVIA_Direct_Mail_Consent__c != oldContact.IQVIA_Direct_Mail_Consent__c) {
                con.IQVIA_Direct_Mail_Consent_Time__c = Datetime.now();
            }
            if (
                con.IQVIA_Assisted_Dialing_Consent__c !=
                oldContact.IQVIA_Assisted_Dialing_Consent__c
            ) {
                con.IQVIA_Assisted_Dialing_Consent_Time__c = Datetime.now();
            }
            if (
                con.IQVIA_Artificial_Voice_Consent__c !=
                oldContact.IQVIA_Artificial_Voice_Consent__c
            ) {
                con.IQVIA_Artificial_Voice_Consent_Time__c = Datetime.now();
            }
        }
    }
    
    @TestVisible
    private static void updateParticipantConsent(List<Contact> newList, Map<Id, Contact> oldMap) {
        for (Contact con : newList) {
            if (oldMap == null) {
                con.IQVIA_Assisted_Dialing_Consent__c = (con.Participant_Phone_Opt_In_Permit_Phone__c
                                                         ? true
                                                         : false);
                con.IQVIA_Artificial_Voice_Consent__c = (con.Participant_Phone_Opt_In_Permit_Phone__c
                                                         ? true
                                                         : false);
                con.IQVIA_Pre_recorded_Voice_Consent__c = (con.Participant_Phone_Opt_In_Permit_Phone__c
                                                           ? true
                                                           : false);
            } else {
                contact oldContact = oldMap.get(con.Id);
                if (
                    con.Participant_Phone_Opt_In_Permit_Phone__c !=
                    oldContact.Participant_Phone_Opt_In_Permit_Phone__c &&
                    con.Participant_Phone_Opt_In_Permit_Phone__c
                ) {
                    con.IQVIA_Assisted_Dialing_Consent__c = true;
                    con.IQVIA_Artificial_Voice_Consent__c = true;
                    con.IQVIA_Pre_recorded_Voice_Consent__c = true;
                } else if (
                    con.Participant_Phone_Opt_In_Permit_Phone__c !=
                    oldContact.Participant_Phone_Opt_In_Permit_Phone__c &&
                    !con.Participant_Phone_Opt_In_Permit_Phone__c
                ) {
                    con.IQVIA_Assisted_Dialing_Consent__c = false;
                    con.IQVIA_Artificial_Voice_Consent__c = false;
                    con.IQVIA_Pre_recorded_Voice_Consent__c = false;
                }
            }
        }
    }
}
