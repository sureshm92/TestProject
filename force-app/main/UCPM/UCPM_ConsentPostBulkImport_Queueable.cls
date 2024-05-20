public without sharing class UCPM_ConsentPostBulkImport_Queueable implements Queueable, Database.AllowsCallouts {
    String accessToken;
    List<Id> perRecIds;
    List<Id> pDelEnrolRecIds;
    String createtypeIdentity;
    String updatetypeIdentity;
    String createrequestJSON;
    String updaterequestJSON;
    public UCPM_ConsentPostBulkImport_Queueable(List<Id> perIdList, List<Id> pderEnrolIds) {
        perRecIds = perIdList != null ? perIdList : null;
        pDelEnrolRecIds = pderEnrolIds != null ? pderEnrolIds : null;
    }

    public void execute(QueueableContext context) {
        fetchPerAndPderDetails(perRecIds, pDelEnrolRecIds);
    }
    public void fetchPerAndPderDetails(List<Id> perIds, List<Id> pderIds) {
        List<Participant_Enrollment__c> perList;
        Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>> perandPderMap = new Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>>();
        if (pderIds != null && pderIds.size() > 0 && perIds != null && perIds.size() > 0) {
            perList = [
                SELECT
                    Id,
                    Participant__r.First_Name__c,
                    Participant__r.Last_Name__c,
                    Participant__r.Birth_Year__c,
                    Participant__r.Phone__c,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                    Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                    Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Participant_Contact__r.PPM_ID__c,
                    Participant__r.Mailing_Country_Code__c,
                    Permit_Mail_Email_contact_for_this_study__c,
                    Permit_SMS_Text_for_this_study__c,
                    Permit_Voice_Text_contact_for_this_study__c,
                    Study_Direct_Mail_Consent__c,
                    PPMID__c,
                    (
                        SELECT
                            Id,
                            Patient_Delegate__c,
                            Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c,
                            Patient_Delegate__r.Participant_Delegate__r.Id,
                            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                            Patient_Delegate__r.Participant_Delegate__r.Email__c,
                            Patient_Delegate__r.Participant_Delegate__r.Phone__c,
                            Patient_Delegate__r.Participant_Delegate__r.Birth_Year__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                            Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                            Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                            Study_Phone_Consent__c,
                            Study_Email_Consent__c,
                            Study_SMS_Consent__c,
                            Study_Direct_Mail_Consent__c,
                            Status__c,
                            PPM_ID__c,
                            Primary_Delegate__c,
                            Patient_Delegate__r.Contact__r.PPM_ID__c
                        FROM Patient_Delegate_Enrollments__r
                        WHERE ID IN :pderIds
                    )
                FROM Participant_Enrollment__c
                WHERE id IN :perIds
            ];


            if (!perList.isEmpty()) {
                for (Participant_Enrollment__c per : perList) {
                    perandPderMap.put(per, per.Patient_Delegate_Enrollments__r);
                }
            }
        } else if (
            perIds != null &&
            perIds.size() > 0 &&
            (pderIds == null ||
            pderIds.size() == 0)
        ) {
            perList = [
                SELECT
                    Id,
                    Participant__r.First_Name__c,
                    Participant__r.Last_Name__c,
                    Participant__r.Birth_Year__c,
                    Participant__r.Phone__c,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                    Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                    Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Participant_Contact__r.PPM_ID__c,
                    Participant__r.Mailing_Country_Code__c,
                    Permit_Mail_Email_contact_for_this_study__c,
                    Permit_SMS_Text_for_this_study__c,
                    Permit_Voice_Text_contact_for_this_study__c,
                    Study_Direct_Mail_Consent__c,
                    PPMID__c
                FROM Participant_Enrollment__c
                WHERE id IN :perIds
            ];
        }

        if (perList != null && perList.size() > 0) {
            for (Participant_Enrollment__c per : perList) {
                //New PER and new participant contact without delegate
                if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per).size() == 0
                ) {
                    createtypeIdentity = 'PARTICIPANT';
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        null,
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant:ParticipantContact'
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                }
                //New PER,existing participant contact without delegate
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per).size() == 0
                ) {
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT';
                    updatetypeIdentity = 'PARTICIPANT';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        null,
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant'
                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        null,
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'ParticipantContact'
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER ,new participant contact,new delegate and new delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c == null
                ) {
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant:ParticipantContact:Delegate:DelegateContact'
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                }
                //New PER,new participant contact,new delegate,existing delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null
                ) {
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant:ParticipantContact:Delegate'
                    );

                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'DelegateContact'
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER,old participant contact,new delegate,new delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c == null
                ) {
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'PARTICIPANT';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant:Delegate:DelegateContact'
                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        null,
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'ParticipantContact'
                    );

                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER,old participant contact,new delegate,old delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null
                ) {
                    accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'PARTICIPANT-DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'Participant:Delegate'
                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        perandPderMap.get(per),
                        per.Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                        'ParticipantContact:DelegateContact'
                    );

                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
            }
        }
    }
}