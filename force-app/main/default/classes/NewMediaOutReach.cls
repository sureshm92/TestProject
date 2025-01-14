/**
*  @Name: newMediaOutReach
*  @Description - This class helps to create new media outReach and 
load the data from logged in community
*  @Author : Vicky
*  @created  2020-05-22
* @version 48.0   
*/
public without sharing class NewMediaOutReach {
    public static String REQUESTED_VAL = Label.Requested;
    public static String REQUESTED_STATUS = 'Requested';

    public static Id studyContactId;
    public static String lstvalsite;
    public static string lstvalstudy;
    public static List<Study_Site__c> studyDataLast;
    public static List<Study_Site__c> piAsDelagted;
    //public static User usrLst;

    public class CommunityPreferred {
        @AuraEnabled
        public string preEmail;
        @AuraEnabled
        public string prePhone;
        @AuraEnabled
        public string studyName;

        public CommunityPreferred() {
        }
    }
    /**
     * @Author: Vicky
     * @name: getstudyType
     * @CreateDate: 2020-05-25
     * @Description: To Pass the phone from study site and email from logged in community user on component.
     **/
    @AuraEnabled
    public static string getstudyType(string site) {
        List<Study_Site__c> studylst = new List<Study_Site__c>();
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();

        Contact userContact = CommunityService.getUserContact();
        studyContactId = userContact.Id;

        if ((String.isNotBlank(site))) {
            Study_Site__c siteId = [
                SELECT id, Name, Study_Site_Phone__c
                FROM Study_Site__c
                WHERE Name = :site
                LIMIT 1
            ];
            lstvalsite = siteId.Study_Site_Phone__c;
        }

        Contact con = [
            SELECT id, name, Email, Phone
            FROM Contact
            WHERE Id = :studyContactId
            LIMIT 1
        ];
        CommunityPreferred commm = new CommunityPreferred();

        commm.prePhone = lstvalsite;
        commm.preEmail = con.Email;

        return JSON.serialize(commm);
    }
    /**
     * @Author: Vicky
     * @name: getstudyData
     * @CreateDate: 2020-05-25
     * @Description: To Pass the list of study.
     **/

    @AuraEnabled
    public static List<NewMediaOutReach.CommunityPreferred> getstudyData(string dataStudy) {
        List<NewMediaOutReach.CommunityPreferred> result = new List<NewMediaOutReach.CommunityPreferred>();
        NewMediaOutReach.CommunityPreferred studyPoistion;
        Clinical_Trial_Profile__c ctpdata;
        Id studyContactId;
        Contact userContact = CommunityService.getUserContact();

        studyContactId = userContact.Id;
        Contact con = [
            SELECT id, UserCommunityIsDelegate__c
            FROM Contact
            WHERE Id = :studyContactId
            LIMIT 1
        ];
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();

        //for PI

        if ((String.isNotBlank(dataStudy))) {
            ctpdata = [
                SELECT id, Study_Code_Name__c, Name
                FROM Clinical_Trial_Profile__c
                WHERE Study_Code_Name__c = :dataStudy
                LIMIT 1
            ];
        }
        if (studyContactId != null && con.UserCommunityIsDelegate__c == false) {
            if (ctpdata != null) {
                studyDataLast = [
                    SELECT id, Site__r.Name, Clinical_Trial_Profile__r.Study_Code_Name__c, Name
                    FROM Study_Site__c
                    WHERE
                        Clinical_Trial_Profile__c = :ctpdata.Id
                        AND Principal_Investigator__c = :studyContactId
                    LIMIT :limitRows
                ];
                for (Study_Site__c sc : studyDataLast) {
                    studyPoistion = new NewMediaOutReach.CommunityPreferred();
                    studyPoistion.studyName = sc.Name;
                    result.add(studyPoistion);
                }
                //PI as delegated starts from here
                List<id> piAsDelStudSiteIds = new List<Id>();
                List<Site_Staff__c> PiAsDelsitestaff = [
                    SELECT
                        id,
                        Delegate_Level__c,
                        Study_Site__r.Clinical_Trial_Profile__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c,
                        Study_Site__c,
                        Site_Contact__c,
                        is_Invited__c
                    FROM Site_Staff__c
                    WHERE
                        Site_Contact__c = :studyContactId
                        AND Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c != NULL
                        AND Study_Site__r.Clinical_Trial_Profile__c = :ctpdata.id
                        AND is_Invited__c = TRUE
                    LIMIT :limitRows
                ];
                for (Site_Staff__c piAsdel : PiAsDelsitestaff) {
                    piAsDelStudSiteIds.add(piAsdel.Study_Site__c);
                }
                if (!piAsDelStudSiteIds.isEmpty()) {
                    piAsDelagted = [
                        SELECT id, Site__r.Name, Clinical_Trial_Profile__r.Study_Code_Name__c, Name
                        FROM Study_Site__c
                        WHERE id IN :piAsDelStudSiteIds
                        LIMIT :limitRows
                    ];
                    for (Study_Site__c sc : piAsDelagted) {
                        studyPoistion = new NewMediaOutReach.CommunityPreferred();
                        studyPoistion.studyName = sc.Name;
                        result.add(studyPoistion);
                    }
                }
                //PI as delegated End from here
            }
        }
        //for PI staff
        if (studyContactId != null && con.UserCommunityIsDelegate__c == true) {
            if (ctpdata != null) {
                List<id> studySiteIds = new List<Id>();
                List<Site_Staff__c> sitestaffDetails = [    SELECT
                        id,  Delegate_Level__c,  Study_Site__r.Clinical_Trial_Profile__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c,
                        Study_Site__c, Site_Contact__c,  is_Invited__c   FROM Site_Staff__c
                    WHERE   Site_Contact__c = :studyContactId  AND Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c != NULL
                        AND Study_Site__r.Clinical_Trial_Profile__c = :ctpdata.id  AND is_Invited__c = TRUE    LIMIT :limitRows  ];
                for (Site_Staff__c sitestaff : sitestaffDetails) {
                    studySiteIds.add(sitestaff.Study_Site__c);
                }
                if (!studySiteIds.isEmpty()) {
                    studyDataLast = [ SELECT id, Site__r.Name, Clinical_Trial_Profile__r.Study_Code_Name__c, Name
                        FROM Study_Site__c  WHERE id IN :studySiteIds   LIMIT :limitRows   ];
                    for (Study_Site__c sc : studyDataLast) {
                        studyPoistion = new NewMediaOutReach.CommunityPreferred();
                        studyPoistion.studyName = sc.Name;
                        result.add(studyPoistion);
                    }
                }
            }
        }
        return result;
    }
    /**
     * @Author: Vicky
     * @name: getstudyData
     * @CreateDate: 2020-05-25
     * @Description: To fetch the Media outreach Provider not null.
     **/
    @AuraEnabled
    public static List<Clinical_Trial_Profile__c> getstudyContact() {
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Id studyContactId;
        List<Clinical_Trial_Profile__c> clinicalTrialLst = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> studylst = new List<Study_Site__c>();
        List<Site_Staff__c> siteStaff = new List<Site_Staff__c>();
        Contact con;
        set<Id> ctpIds = new Set<Id>();
        Contact userContact = CommunityService.getUserContact();

        studyContactId = userContact.Id;
        system.System.debug('studyContactId??' + studyContactId);
        con = [
            SELECT id, UserCommunityIsDelegate__c
            FROM Contact
            WHERE Id = :studyContactId
            LIMIT 1
        ];

        if (studyContactId != null && con.UserCommunityIsDelegate__c == false) {
            studylst = [
                SELECT
                    id,
                    Name,
                    Clinical_Trial_Profile__r.Media_outreach_Provider__c,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Principal_Investigator__c
                FROM Study_Site__c
                WHERE
                    Principal_Investigator__c = :studyContactId
                    AND Clinical_Trial_Profile__r.Media_outreach_Provider__c != NULL
                LIMIT :limitRows
            ];
            siteStaff = [
                SELECT
                    id,
                    Delegate_Level__c,
                    Study_Site__r.Clinical_Trial_Profile__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c,
                    Study_Site__c,
                    Site_Contact__c,
                    is_Invited__c
                FROM Site_Staff__c
                WHERE
                    Site_Contact__c = :studyContactId
                    AND Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c != NULL
                    AND is_Invited__c = TRUE
                LIMIT :limitRows
            ];
        }

        if (studyContactId != null && con.UserCommunityIsDelegate__c == true) {
            siteStaff = [  SELECT  id,  Delegate_Level__c,  Study_Site__r.Clinical_Trial_Profile__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c,  Study_Site__c,
                    Site_Contact__c,  is_Invited__c   FROM Site_Staff__c 
                     WHERE  Site_Contact__c = :studyContactId
                    AND Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c != NULL   AND is_Invited__c = TRUE LIMIT :limitRows ];
        }

        if (studylst.size() > 0) {
            for (Study_Site__c st : studylst) {
                ctpIds.add(st.Clinical_Trial_Profile__c);
            }
        }
        if (siteStaff.size() > 0) {
            for (Site_Staff__c ss : siteStaff) {
                ctpIds.add(ss.Study_Site__r.Clinical_Trial_Profile__c);
            }
        }
        if (!ctpIds.isEmpty()) {
            clinicalTrialLst = [
                SELECT id, Study_Code_Name__c, Name   FROM Clinical_Trial_Profile__c
                WHERE Id = :ctpIds  AND CommunityTemplate__c NOT IN :MediaOutreachServices.RESTRICTED_COMMUNITY_TEMPLATES  LIMIT :limitRows ];
        }

        return clinicalTrialLst;
    }
    /**
     * @Author: Vicky
     * @name: getPickListValues
     * @CreateDate: 2020-05-29
     * @Description: To fetch the Media type value from media outreach object.
     **/

    @AuraEnabled
    public static Map<String, String> getPickListValues(String obj, String str) {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult plistvalues = Schema.getGlobalDescribe()
            .get(obj)
            .getDescribe()
            .fields.getMap()
            .get(str)
            .getDescribe();

        for (PicklistEntry ent : plistvalues.getpicklistvalues()) {
            //options.put(ent.getValue(),ent.getLabel());
            options.put(
                TranslateHelper.getPickListLabel(Media_Outreach__c.Media_Type__c, ent.getLabel()),
                ent.getLabel()
            );
        }
        return options;
    }

    /**
     * @Author: Vicky
     * @name: getPickListValues
     * @CreateDate: 2020-05-29
     * @Description: To create media outreach data.
     **/

    @AuraEnabled
    public static void inviteNewMedia(
        string study,
        string site,
        String prefferedtype,
        string actualemailPhone,
        List<String> media,
        string startdt,
        string enddt,
        string notes
    ) {
        try {
            Clinical_Trial_Profile__c ctpLstdata;
            User usrLst;
            UserRecordAccess usrAccess;
            ObjectPermissions objPermission;
            string ctpprofileId;
            string mediaAccessId;
            Study_Site__c siteId;

            if (study != '' || study != null) {
                ctpLstdata = [
                    SELECT
                        id,
                        Study_Code_Name__c,
                        Name,
                        Media_outreach_Provider__c,
                        Media_outreach_Provider__r.Id
                    FROM Clinical_Trial_Profile__c
                    WHERE Study_Code_Name__c = :study
                    LIMIT 1
                ];
            }
            if (ctpLstdata != null && (site != '' || site != null)) {
                siteId = [
                    SELECT
                        id,
                        Site__c,
                        Name,
                        Principal_Investigator__c,
                        Principal_Investigator__r.FirstName,
                        Principal_Investigator__r.LastName
                    FROM Study_Site__c
                    WHERE Clinical_Trial_Profile__c = :ctpLstdata.Id AND Name = :site
                    LIMIT 1
                ];
            }
            //system.debug('ctpLstdata.Media_outreach_Provider__cLINE198>>'+ctpLstdata.Media_outreach_Provider__c);
            if (ctpLstdata != null) {
                mediaAccessId = ctpLstdata.Media_outreach_Provider__c;
            }
            //system.debug('mediaAccessIdLINE200>>'+mediaAccessId);
            if (mediaAccessId != null) {
                //system.debug('mediaAccessId>>'+mediaAccessId);
                usrLst = [SELECT id, profileId FROM User WHERE Id = :mediaAccessId LIMIT 1];
                system.debug('usrLst>>' + usrLst);
            }
            ctpprofileId = usrLst.profileId;
            //system.debug('ctpprofileId>>'+ctpprofileId);
           /* if (ctpprofileId != null) {
                objPermission = [
                    SELECT Id, SObjectType, PermissionsRead, PermissionsCreate
                    FROM ObjectPermissions
                    WHERE
                        SObjectType = 'Media_Outreach__c'
                        AND parentid IN (
                            SELECT id
                            FROM permissionset
                            WHERE PermissionSet.Profile.Id = :ctpprofileId
                        )
                    LIMIT 1
                ];
            } */

            List<Media_Outreach__c> medialst = new List<Media_Outreach__c>();
            string typeval;
            Media_Outreach__c mediaOut = new Media_Outreach__c();
            if (media.size() > 0) {
                for (Integer i = 0; i < media.size(); i++) {
                    if (i == 0) {
                        typeval = media[i];
                    }
                    if (i > 0) {
                        typeval = typeval + ';' + media[i];
                    }
                }
            }
            mediaOut.Clinical_Trial_Profile__c = ctpLstdata.Study_Code_Name__c;
            mediaOut.Study_Name__c = siteId.Id;
            mediaOut.Media_Type__c = typeval;
            mediaOut.Preferred_contact_method__c = prefferedtype;
            mediaOut.Alternate_Email_Phone_Number__c = actualemailPhone;
            mediaOut.Status__c = REQUESTED_STATUS;
            if (startdt != '') {
                mediaOut.Requested_Start_Date__c = Date.valueOf(startdt);
            }
            if (enddt != '') {
                mediaOut.Requested_End_Date__c = Date.valueOf(enddt);
            }
            medialst.add(mediaOut);

            if (medialst.size() > 0) {
                insert medialst;
            }
            usrAccess = [
                SELECT RecordId, HasEditAccess
                FROM UserRecordAccess
                WHERE UserId = :mediaAccessId AND RecordId = :medialst[0].Id
            ];
            //Task Creation
            if (medialst.size() > 0) {
                if (
                    ctpLstdata.Media_outreach_Provider__c != null &&
                    usrAccess.HasEditAccess == true
                ) {
                    Task tsk = new Task();
                    tsk.ActivityDate = System.today().addDays(3);
                    tsk.OwnerId = ctpLstdata.Media_outreach_Provider__c;
                    tsk.Priority = 'Normal';
                    tsk.Status = 'Open';
                    tsk.WhatId = medialst[0].Id;
                    tsk.Subject =
                        'New media outreach request from PI' +
                        '  ' +
                        siteId.Principal_Investigator__r.FirstName +
                        ' ' +
                        siteId.Principal_Investigator__r.LastName;
                    insert tsk;
                }
            }
            if (String.isNotBlank(notes) && usrAccess.HasEditAccess == true) {
                ContentNote objCntNote = new ContentNote();
                objCntNote.Title = notes;
                insert objCntNote;

                ContentDocumentLink objCntDocLink = new ContentDocumentLink();
                objCntDocLink.LinkedEntityId = medialst[0].Id;
                objCntDocLink.ContentDocumentId = objCntNote.Id;
                insert objCntDocLink;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}