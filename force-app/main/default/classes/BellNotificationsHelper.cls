/*********************************************************************************************************************
* @description: This class is created to handle Notifications of type 'BELL'
*
* @created: 13 October 2022

**********************************************************************************************************************
* Modification Log
* Version			Developer		Date			Remarks
*---------------------------------------------------------------------------------------------------------------------
*
**********************************************************************************************************************
*/
public class BellNotificationsHelper {
    public static String userRole;

/*
    * @description: This Method will return all the Notification Target records for Notification Type
    * RH-6603
    * @created: 17 Oct 2022
    * @param: notificationType
    * @return: List<Notification_Target__mdt>
    * */
    public static List<Notification_Target__mdt> getTarget(String notificationType){
        if(!String.isBlank(notificationType)){
            Map<String, List<Notification_Target__mdt>> mapOfTypeVsTarget = new Map<String, List<Notification_Target__mdt>>();
            mapOfTypeVsTarget = getMapOfTypeVsTarget(new List<String>{notificationType});
            if(!mapOfTypeVsTarget.isEmpty() && mapOfTypeVsTarget.containsKey(notificationType)){
                return mapOfTypeVsTarget.get(notificationType);
            }
        }
        return null;
    }


/*
    * @description: This Method will return all the Notification Target records for Notification Type in a Map
    * RH-6603
    * @created: 17 Oct 2022
    * @param: notificationType
    * @return: Map<NotificationType.DeveloperName, List<Notification_Target__mdt>>
    * */
    public static Map<String, List<Notification_Target__mdt>> getMapOfTypeVsTarget(List<String> lstnotificationType){
        List<Notification_Target__mdt> lstOfNotificationTarget = new List<Notification_Target__mdt>();
        Map<String, List<Notification_Target__mdt>> mapOfTypeVsTarget = new Map<String, List<Notification_Target__mdt>>();

        if(!lstnotificationType.isEmpty() && lstnotificationType.size() > 0){
            lstOfNotificationTarget = [SELECT Message_Body__c, Notification_Type__r.DeveloperName, Notification_Type__r.MasterLabel,
                                       Notification_Type__c, Target_Type__c, Title__c, Target_User_Group__c, Is_Redirect__c
                                       FROM Notification_Target__mdt
                                       WHERE Notification_Type__r.DeveloperName IN :lstnotificationType];
            if(lstOfNotificationTarget.size() > 0){
                for(Notification_Target__mdt eachRec : lstOfNotificationTarget){
                    if(!mapOfTypeVsTarget.containsKey(eachRec.Notification_Type__r.DeveloperName)){
                        mapOfTypeVsTarget.put(eachRec.Notification_Type__r.DeveloperName, new List<Notification_Target__mdt>{});
                    }
                    mapOfTypeVsTarget.get(eachRec.Notification_Type__r.DeveloperName).add(eachRec);
                }
                return mapOfTypeVsTarget;
            }
        }
        return null;
    }

    /*
    * @description: This Method will return all the Contact records to whom Notification have to be sent in a Map Key - TargetUserGroup
    * RH-6603
    * @created: 17 Oct 2022
    * @param: List of TargetUserGroup, StudySiteId, User who trigerred the process
    * @return: Map<String TargetUserGroup, List<Contact>>
    * */

    public static Map<String, List<Contact>> getRecipientVsContact(List<String> userTargetGroup, Id studySite, String trigerredBy){
        Map<String, List<Contact>> mapofGroupVsContact = new Map<String, List<Contact>>();
        List<Study_Site__c> lstOfSite = new List<Study_Site__c>();


        for(String eachRec : userTargetGroup){
            if(!mapofGroupVsContact.containsKey(eachRec)){
                mapofGroupVsContact.put(eachRec, new List<Contact>{});
            }
        }

        List<String> delegateLevel = new List<String>();
        if (mapofGroupVsContact.containsKey('PI Delegate L1')) {
            delegateLevel.add('Level 1');
        }
        if (mapofGroupVsContact.containsKey('PI Delegate L2')) {
            delegateLevel.add('Level 2');
        }
        if (mapofGroupVsContact.containsKey('PI Delegate L3')) {
            delegateLevel.add('Level 3');
        }

        lstOfSite = [SELECT Id, Principal_Investigator__c, (SELECT Id, Site_Contact__c, Delegate_Level__c FROM Site_Staff__r WHERE Delegate_Level__c IN :delegateLevel AND is_Invited__c = TRUE), (SELECT ID, HCP_Contact__c FROM HCP_Enrollments__r WHERE Status__c = 'Activated') FROM Study_Site__c WHERE ID = :studySite];

        for (Study_Site__c eachRec: lstOfSite){
            if(mapofGroupVsContact.containsKey('Self') && !String.isBlank(trigerredBy)){
                mapofGroupVsContact.get('Self').add(new Contact(Id = trigerredBy));
            }

            if(mapofGroupVsContact.containsKey('PI') && eachRec.Principal_Investigator__c != null && eachRec.Principal_Investigator__c != trigerredBy){
                mapofGroupVsContact.get('PI').add(new Contact(Id = eachRec.Principal_Investigator__c));
            }else{
                userRole = 'PI';
            }

            if(eachRec.Site_Staff__r != null){
                for(Site_Staff__c eachStaff : eachRec.Site_Staff__r){
                    if(eachStaff.Site_Contact__c != trigerredBy){
                        if(eachStaff.Delegate_Level__c == 'Level 1' && mapofGroupVsContact.containsKey('PI Delegate L1')){
                        mapofGroupVsContact.get('PI Delegate L1').add(new Contact(Id = eachStaff.Site_Contact__c));
                        }
                        if(eachStaff.Delegate_Level__c == 'Level 2' && mapofGroupVsContact.containsKey('PI Delegate L2')){
                            mapofGroupVsContact.get('PI Delegate L2').add(new Contact(Id = eachStaff.Site_Contact__c));
                        }
                        if(eachStaff.Delegate_Level__c == 'Level 3' && mapofGroupVsContact.containsKey('PI Delegate L3')){
                            mapofGroupVsContact.get('PI Delegate L3').add(new Contact(Id = eachStaff.Site_Contact__c));
                        }
                    }else {
                        if(eachStaff.Delegate_Level__c == 'Level 1' || eachStaff.Delegate_Level__c == 'Level 2' || eachStaff.Delegate_Level__c == 'Level 3'){
                            userRole = 'PI';
                        }
                    }
                }
            }
            if(mapofGroupVsContact.containsKey('RP') && eachRec.HCP_Enrollments__r != null){
                for(HCP_Enrollment__c eachRP : eachRec.HCP_Enrollments__r){
                    if(eachRP.HCP_Contact__c != trigerredBy){
                        mapofGroupVsContact.get('RP').add(new Contact(Id = eachRP.HCP_Contact__c));
                    }else{
                        userRole = 'RP';
                    }
                }
            }
        }
        return mapofGroupVsContact;
    }


    //OverLoaded Method
    public static Map<String, List<Contact>> getRecipientVsContact(List<String> userTargetGroup, Id studySite){
        return getRecipientVsContact(userTargetGroup, studySite, null);
    }

    /*
    * @description: This Method will return all the Notifaction Record created
    * RH-6603
    * @created: 17 Oct 2022
    * @param: List of NotificationType, Map of TargetUserGroup VS List of Contacts, isInsert
    * @return: List<Notification__c>
    * */
    public static List<Notification__c> createNotification(String notificationType, Map<String, List<Contact>> mapofGroupVsContact, Boolean isInsert){
        List<Notification__c> lstOfNotification = new List<Notification__c>();

        for(String eachKey : mapofGroupVsContact.keySet()){
            for(Contact con : mapofGroupVsContact.get(eachKey)){
                Notification__c nRec = new Notification__c(Recipient__c = con.Id, Notification_Type__c = notificationType, Target_User_Group__c = eachKey);
                lstOfNotification.add(nRec);
            }
        }
        if(isInsert){
            insert lstOfNotification;
        }
        return lstOfNotification;
    }

    public static List<Notification__c> createNotification(String notificationType, Map<String, List<Contact>> mapofGroupVsContact, String communityType, Id whatId, Boolean isInsert){
        List<Notification__c> lstOfNotification = new List<Notification__c>();

        for(String eachKey : mapofGroupVsContact.keySet()){
            for(Contact con : mapofGroupVsContact.get(eachKey)){
                Notification__c nRec = new Notification__c(Recipient__c = con.Id, Notification_Type__c = notificationType, Target_User_Group__c = eachKey, Community_Type__c = communityType, WhatId__c = whatId);
                lstOfNotification.add(nRec);
            }
        }
        if(isInsert){
            insert lstOfNotification;
        }
        return lstOfNotification;
    }

    /*
    * @description: This Method will return all the Notification Record created
    * RH-6603
    * @created: 17 Oct 2022
    * @param: NotificationType, recipient COntact, isInsert
    * @return: Notification__c
    * */
    public static Notification__c createNotification(String notificationType, Id contactId, Boolean isInsert){
        Notification__c nRec = new Notification__c();
        if(!String.isBlank(notificationType) && contactId != null){
            nRec.Recipient__c = contactId;
            nRec.Notification_Type__c = notificationType;
        }

        if(isInsert){
            insert nRec;
        }

        return nRec;
    }

    /*
    * @description: This Method will return all the Notification Record created
    * RH-6603
    * @created: 17 Oct 2022
    * @param: NotificationType, recipient COntact, whatId, isInsert
    * @return: Notification__c
    * */
    public static Notification__c createNotification(String notificationType, Id contactId, String whatId, Boolean isInsert){
        Notification__c nRec = new Notification__c();
        if(!String.isBlank(notificationType) && contactId != null && !String.isBlank(whatId)){
            nRec.Recipient__c = contactId;
            nRec.Notification_Type__c = notificationType;
            nRec.WhatId__c = whatId;
        }

        if(isInsert){
            insert nRec;
        }

        return nRec;
    }

    public static Notification__c createNotification(String notificationType, Id contactId, String userRole, String communityType, Boolean isInsert){
        Notification__c nRec = new Notification__c();
        if(!String.isBlank(notificationType) && contactId != null && !String.isBlank(userRole) && !String.isBlank(communityType)){
            nRec.Recipient__c = contactId;
            nRec.Notification_Type__c = notificationType;
            nRec.Target_User_Group__c = userRole;
            nRec.Community_Type__c = communityType;
        }

        if(isInsert){
            insert nRec;
        }

        return nRec;
    }

    public static List<Contact> getContactForStudy(Id studyId){
        List<Study_Site__c> lstOfStaff = new List<Study_Site__c>();
        List<String> lstOfUniqueContacts = new List<String>();
        List<Contact> lstOfContacts = new List<Contact>();
        if(studyId != null){
            lstOfStaff = [SELECT ID, Principal_Investigator__c,  (SELECT Id, Site_Contact__c, Delegate_Level__c FROM Site_Staff__r WHERE is_Invited__c = TRUE) FROM Study_Site__c WHERE Clinical_Trial_Profile__c = :studyId];
        }

        for(Study_Site__c eachRec : lstOfStaff){
            if(!lstOfUniqueContacts.contains(eachRec.Principal_Investigator__c)){
                lstOfUniqueContacts.add(eachRec.Principal_Investigator__c);
                Contact con = new Contact(Id = eachRec.Principal_Investigator__c);
                lstOfContacts.add(con);
            }

            if(eachRec.Site_Staff__r != null){
                for(Site_Staff__c eachStaff : eachRec.Site_Staff__r){
                    if(!lstOfUniqueContacts.contains(eachStaff.Site_Contact__c)){
                        lstOfUniqueContacts.add(eachStaff.Site_Contact__c);
                        Contact con = new Contact(Id = eachStaff.Site_Contact__c);
                        lstOfContacts.add(con);
                    }
                }
            }
        }

        return lstOfContacts;

    }

    public static Map<String, List<Contact>> getContactForStudy(List<Id> studyIds){
        List<Study_Site__c> lstOfStaff = new List<Study_Site__c>();
        Map<String, List<Contact>> mapOfStudyContact = new Map<String, List<Contact>>();

        if(studyIds != null){
            lstOfStaff = [SELECT ID, Principal_Investigator__c,  Clinical_Trial_Profile__c, (SELECT Id, Site_Contact__c, Delegate_Level__c FROM Site_Staff__r WHERE is_Invited__c = TRUE) FROM Study_Site__c WHERE Clinical_Trial_Profile__c IN :studyIds];
        }

        for(Study_Site__c eachRec : lstOfStaff){
            if(!mapOfStudyContact.containsKey(eachRec.Clinical_Trial_Profile__c)){
                mapOfStudyContact.put(eachRec.Clinical_Trial_Profile__c, new List<Contact>{});
            }

            Contact con = new Contact(Id = eachRec.Principal_Investigator__c);
            mapOfStudyContact.get(eachRec.Clinical_Trial_Profile__c).add(con);

            if(eachRec.Site_Staff__r != null){
                for(Site_Staff__c eachStaff : eachRec.Site_Staff__r){
                    Contact con1 = new Contact(Id = eachStaff.Site_Contact__c);
                    mapOfStudyContact.get(eachRec.Clinical_Trial_Profile__c).add(con1);
                }
            }
        }

        return mapOfStudyContact;

    }

    public static Map<String, Set<String>> getContactForSites(Set<String> studySites){
        List<Study_Site__c> lstOfStaff = new List<Study_Site__c>();
        Map<String, Set<String>> mapofSiteVsContact = new Map<String, Set<String>>();

        lstOfStaff = [SELECT ID, Principal_Investigator__c,  (SELECT Id, Site_Contact__c, Delegate_Level__c FROM Site_Staff__r WHERE is_Invited__c = TRUE) FROM Study_Site__c WHERE ID IN :studySites];

        for(Study_Site__c eachRec : lstOfStaff){
            for(Site_Staff__c eachStaff : eachRec.Site_Staff__r){
                if(!mapofSiteVsContact.containsKey(eachRec.Id)){
                    mapofSiteVsContact.put(eachRec.Id, new Set<String>{eachRec.Principal_Investigator__c});
                }
                mapofSiteVsContact.get(eachRec.Id).add(eachStaff.Site_Contact__c);
            }
        }

        return mapofSiteVsContact;
    }

    public static List<Contact> getContactGeneric(){
        List<Study_Site__c> lstOfStaff = new List<Study_Site__c>();
        Set<String> setOfUniqueContacts = new Set<String>();
        List<Site_Staff__c> lstOfSiteStaff = new List<Site_Staff__c>();
        List<Contact> lstOfContacts = new List<Contact>();

        lstOfStaff = [SELECT ID, Principal_Investigator__c,  (SELECT Id, Site_Contact__c, Delegate_Level__c FROM Site_Staff__r WHERE is_Invited__c = TRUE) FROM Study_Site__c];


        for(Study_Site__c eachRec : lstOfStaff){
            setOfUniqueContacts.add(eachRec.Principal_Investigator__c);

            if(eachRec.Site_Staff__r != null){
                lstOfSiteStaff.addAll(eachRec.Site_Staff__r);
            }
        }

        for(Site_Staff__c eachRec : lstOfSiteStaff){
            setOfUniqueContacts.add(eachRec.Site_Contact__c);
        }

        for(String eachrec : setOfUniqueContacts){
            Contact con = new Contact(Id = eachrec);
            lstOfContacts.add(con);
        }

        return lstOfContacts;

    }

    /*
    * @description: this method will publish platform event message for Bell Notification type
    * RH-6603
    * @created: 17 Oct 2022
    * @param: srList => list of Send Result records getting inserted
    * @return: void
    * */
    public static void publishPEForBellNotifications(List<Send_Result__c> srList ){
        List<Send_Result__c> srForBellNotification = new List<Send_Result__c>();
        Set<Id> srIds = new Set<Id>();
        List<bellNotification__e> eventMessages = new List<bellNotification__e>();

        for(Send_Result__c srObj: srList){
            if('Bell'.equalsIgnoreCase(srObj.Target_Type__c) ){
                srForBellNotification.add(srObj);
                srIds.add(srObj.Id);
            }
        }

        if(srForBellNotification.size() > 0){
            Map<Id,Send_Result__c> srMap  = new Map<Id,Send_Result__c>(
                                                    [SELECT Notification__r.Recipient__c FROM Send_Result__c WHERE Id IN :srIds]
                                                );

            for(Send_Result__c srObj : srForBellNotification){
                eventMessages.add(new bellNotification__e(  ContactId__c = srMap.containsKey(srObj.Id) ?
                                                                            srMap.get(srObj.Id).Notification__r.Recipient__c :
                                                                            '',
                                                            message__c = srObj.Push_Message_Body__c)
                                                        );
            }

            List<Database.SaveResult> results = EventBus.publish(eventMessages);
                // Inspect publishing result for each event
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.🟢');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage());
                        }
                    }
                }
        }
    }

    /*
    * @description: this method will return the Access level of current logged in User for a particular Study Site
    * RH-9210
    * @created: 10 Nov 2022
    * @param: contactId (String) => Current user Contact Id
    * @param: studySiteId (String) => Study Site Id
    * @return: (String) current users access level: PI/Level 1/Level 2/ Level 3
    * */
    public static String getCurrentUserLevelByStudySite(String contactId,String studySiteId){

        List<Study_Site__c> ssList = [SELECT Id, Principal_Investigator__c,
                                        (SELECT Id, Site_Contact__c, Delegate_Level__c
                                            FROM Site_Staff__r
                                            WHERE is_Invited__c = TRUE)
                                        FROM Study_Site__c
                                        WHERE Id = :studySiteId];
        for(Study_Site__c ss : ssList){
            if(String.valueOf(ss.Principal_Investigator__c)?.containsIgnoreCase(contactId) ){
                return 'PI';
            }
            else{
                for(Site_Staff__c staff : ss.Site_Staff__r){
                    if(String.valueOf(staff.Site_Contact__c)?.containsIgnoreCase(contactId) && String.isNotEmpty(staff.Delegate_Level__c) ){
                        switch on staff.Delegate_Level__c {
                            when 'Level 1' {
                                return 'PI Delegate L1';
                            }
                            when 'Level 2' {
                                return 'PI Delegate L2';
                            }
                            when 'Level 3' {
                                return 'PI Delegate L3';
                            }
                        }
                    }
                }
            }
        }
        return 'None';
    }


}