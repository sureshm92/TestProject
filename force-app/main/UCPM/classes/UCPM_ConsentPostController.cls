public class UCPM_ConsentPostController {
    //generate mulesoft access token
    public static String getAccessToken() {
        return MulesoftIntegrationApi.getAccessToken('Mulesoft Access Token UCPM');
    }
    public static void fetchPerAndPderDetails(
        List<Id> perIdList,
        List<Id> pderIdList,
        String placeoffunctionality
    ) {
        List<Participant_Enrollment__c> perList;
        Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>> perandPderMap = new Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>>();
        if (pderIdList != null && pderIdList.size() > 0) {
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
                    DataControllerOrg__c,
                    Participant_Contact__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
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
                        WHERE ID IN :pderIdList
                    )
                FROM Participant_Enrollment__c
                WHERE id IN :perIdList
            ];
            if (pderIdList != null && pderIdList.size() > 0) {
                for (Participant_Enrollment__c per : perList) {
                    perandPderMap.put(per, per.Patient_Delegate_Enrollments__r);
                }
            }
        } else {
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
                    DataControllerOrg__c,
                    Participant_Contact__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
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
                WHERE id IN :perIdList
            ];
        }

        //Checking restricted resource and Iqvia Outreach validation
        list<Restricted_Source_Config__c> restrictedRecrd = new List<Restricted_Source_Config__c>();
        String[] restrictedlst;
        String referralSource;
        Boolean iqviaOutreach = false;
        if (perList[0].Clinical_Trial_Profile__r.IQVIA_Outreach__c) {
            if (
                perList[0].Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal' &&
                (perList[0].Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' ||
                perList[0].Clinical_Trial_Profile__r.PPTemplate__c != 'PP 2.0')
            ) {
                iqviaOutreach = true;
            } else {
                restrictedRecrd = [
                    SELECT
                        Id,
                        Sponsor__c,
                        Study__c,
                        Study__r.IQVIA_Outreach__c,
                        Referral_Resource__c
                    FROM Restricted_Source_Config__c
                    WHERE
                        Study__c = :perList[0].Clinical_Trial_Profile__c
                        AND Referral_Resource__c != NULL
                ];
                if (restrictedRecrd != null && !restrictedRecrd.isEmpty()) {
                    for (Restricted_Source_Config__c rsc : restrictedRecrd) {
                        restrictedlst = rsc.Referral_Resource__c != null
                            ? rsc.Referral_Resource__c.split(';')
                            : null;
                        if (restrictedlst != null && !restrictedlst.isEmpty()) {
                            referralSource = (perList[0].Referral_Source__c == 'ePR' ||
                                perList[0].Referral_Source__c == 'ePRCampaign')
                                ? perList[0].Referral_Source__c +
                                  '-' +
                                  perList[0].DataControllerOrg__c
                                : perList[0].Referral_Source__c;
                            if (restrictedlst.contains(referralSource)) {
                                iqviaOutreach = false;
                                break;
                            } else {
                                iqviaOutreach = true;
                            }
                        }
                    }
                } else {
                    iqviaOutreach = true;
                }
            }
        } else {
            iqviaOutreach = false;
        }

        //if(perandPderMap.keySet() != null){
        for (Participant_Enrollment__c pe : perList) {
            Boolean removeparticipantcontact = false;
            if (
                !pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c &&
                !pe.Participant_Contact__r.Participant_Opt_In_Status_SMS__c &&
                !pe.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c &&
                !pe.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
            ) {
                removeparticipantcontact = true;
            }

            if (placeoffunctionality == 'Referring Provider Participant' && pderIdList == null) {
                //New/Old PER without participant contact
                if (pe.Participant_Contact__c == null) {
                    if (pe.PPMID__c != null) {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Update',
                                iqviaOutreach,
                                'PARTICIPANT',
                                'Participant',
                                placeoffunctionality
                            )
                        );
                    } else {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Create',
                                iqviaOutreach,
                                'PARTICIPANT',
                                'Participant',
                                placeoffunctionality
                            )
                        );
                    }
                }
            }
            //Existing PER with Multiple delegates from Emancipation page
            else if (
                placeoffunctionality == 'Emancipation With Multiple Delegates' &&
                pe.PPMID__c != null &&
                pe.Participant_Contact__c != null &&
                pderIdList != null &&
                pderIdList.size() > 0 &&
                perandPderMap.get(pe) != null &&
                perandPderMap.get(pe).size() > 0
            ) {
                System.enqueueJob(
                    new UCPM_PostConsentQueueable(
                        pe,
                        perandPderMap.get(pe),
                        'Update',
                        iqviaOutreach,
                        'DELEGATE',
                        'Delegate',
                        placeoffunctionality
                    )
                );
            }
            //New PER and new participant contact without delegate
            else if (
                pe.PPMID__c == null &&
                pe.Participant_Contact__c != null &&
                pe.Participant_Contact__r.PPM_ID__c == null &&
                pderIdList == null
            ) {
                System.enqueueJob(
                    new UCPM_PostConsentQueueable(
                        pe,
                        null,
                        'Create',
                        iqviaOutreach,
                        'PARTICIPANT',
                        removeparticipantcontact ? 'Participant' : 'Participant:ParticipantContact',
                        placeoffunctionality
                    )
                );
            }
            //New PER ,new participant contact,new delegate and new delegate contact
            else if (
                pe.PPMID__c == null &&
                pe.Participant_Contact__r.PPM_ID__c == null &&
                pderIdList != null &&
                pderIdList.size() > 0 &&
                perandPderMap.get(pe) != null &&
                perandPderMap.get(pe).size() > 0 &&
                perandPderMap.get(pe)[0].PPM_ID__c == null &&
                perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c == null
            ) {
                System.enqueueJob(
                    new UCPM_PostConsentQueueable(
                        pe,
                        perandPderMap.get(pe),
                        'Create',
                        iqviaOutreach,
                        'PARTICIPANT-DELEGATE',
                        removeparticipantcontact
                            ? 'Participant:Delegate:DelegateContact'
                            : 'Participant:ParticipantContact:Delegate:DelegateContact',
                        placeoffunctionality
                    )
                );
            }
            //New PER,existing participant contact without delegate
            else if (
                pe.PPMID__c == null &&
                pe.Participant_Contact__r.PPM_ID__c != null &&
                pderIdList == null
            ) {
                if (removeparticipantcontact) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            null,
                            'Create',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'Participant',
                            placeoffunctionality
                        )
                    );
                } else {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            null,
                            'Both',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'Participant',
                            'PARTICIPANT',
                            'ParticipantContact',
                            placeoffunctionality
                        )
                    );
                }
            }
            //New PER,new participant contact,new delegate,existing delegate contact
            else if (
                pe.PPMID__c == null &&
                pe.Participant_Contact__r.PPM_ID__c == null &&
                pderIdList != null &&
                pderIdList.size() > 0 &&
                perandPderMap.get(pe) != null &&
                perandPderMap.get(pe).size() > 0 &&
                perandPderMap.get(pe)[0].PPM_ID__c == null &&
                perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null
            ) {
                if (removeparticipantcontact) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            perandPderMap.get(pe),
                            'Both',
                            iqviaOutreach,
                            'PARTICIPANT-DELEGATE',
                            'Participant:Delegate',
                            'DELEGATE',
                            'DelegateContact',
                            placeoffunctionality
                        )
                    );
                } else {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            perandPderMap.get(pe),
                            'Both',
                            iqviaOutreach,
                            'PARTICIPANT-DELEGATE',
                            'Participant:ParticipantContact:Delegate',
                            'DELEGATE',
                            'DelegateContact',
                            placeoffunctionality
                        )
                    );
                }
            }
            // Existing per,existing participant contact,new delegate and new delegate contact
            else if (
                (placeoffunctionality == 'Sharing Options' ||
                placeoffunctionality == 'Emancipation' ||
                placeoffunctionality == 'PP Manage Delegate') &&
                pe.PPMID__c != null &&
                pderIdList != null &&
                pderIdList.size() > 0
            ) {
                System.enqueueJob(
                    new UCPM_PostConsentQueueable(
                        pe,
                        perandPderMap.get(pe),
                        'Create',
                        iqviaOutreach,
                        'DELEGATE',
                        'Delegate',
                        placeoffunctionality
                    )
                );
            }
            /*
      //Existing per,existing participant contact,new delegate,existing delegate contact
      else if (
        (placeoffunctionality == 'Sharing Options' ||
        placeoffunctionality == 'Emancipation' ||
        placeoffunctionality == 'PP Manage Delegate') &&
        pe.PPMID__c != null &&
        pe.Participant_Contact__r.PPM_ID__c != null &&
        pderIdList != null &&
        pderIdList.size() > 0 &&
        perandPderMap.get(pe)[0].PPM_ID__c == null &&
        perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c !=
        null
      ) {
        System.enqueueJob(
          new UCPM_PostConsentQueueable(
            pe,
            perandPderMap.get(pe),
            'Both',
            iqviaOutreach,
            'DELEGATE',
            'Delegate',
            'DELEGATE',
            'DelegateContact'
          )
        );
      }
      */
            else if (placeoffunctionality == 'Participant Detail') {
                //Existing per,existing participant contact without delegate
                if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c != null &&
                    pderIdList == null
                ) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            null,
                            'Update',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'Participant:ParticipantContact',
                            placeoffunctionality
                        )
                    );
                }
                //Existing per,existing participant contact ,new delegate and new/existing delegate contact
                else if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c != null &&
                    pderIdList != null &&
                    pderIdList.size() > 0 &&
                    perandPderMap.get(pe) != null &&
                    perandPderMap.get(pe).size() > 0 &&
                    perandPderMap.get(pe)[0].PPM_ID__c == null
                ) {
                    //existing delegate contact
                    if (perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null) {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'DELEGATE',
                                'Delegate',
                                'PARTICIPANT-DELEGATE',
                                'Participant:ParticipantContact:DelegateContact',
                                placeoffunctionality
                            )
                        );
                    } else {
                        //new delegate contact
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'DELEGATE',
                                'Delegate:DelegateContact',
                                'PARTICIPANT',
                                'Participant:ParticipantContact',
                                placeoffunctionality
                            )
                        );
                    }
                }
                //Existing per,existing particpant contact,existing delegate and new/existing delegate contact
                else if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c != null &&
                    pderIdList != null &&
                    pderIdList.size() > 0 &&
                    perandPderMap.get(pe) != null &&
                    perandPderMap.get(pe)[0].PPM_ID__c != null
                ) {
                    //existing delegate contact
                    if (perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null) {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Update',
                                iqviaOutreach,
                                'PARTICIPANT-DELEGATE',
                                'Participant:ParticipantContact:Delegate:DelegateContact',
                                placeoffunctionality
                            )
                        );
                    } else {
                        //new delegate contact
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'DELEGATE',
                                'DelegateContact',
                                'PARTICIPANT-DELEGATE',
                                'Participant:ParticipantContact:Delegate',
                                placeoffunctionality
                            )
                        );
                    }
                }
                //Existing per,new participant contact without delegate
                else if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c == null &&
                    pderIdList == null
                ) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            null,
                            'Both',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'ParticipantContact',
                            'PARTICIPANT',
                            'Participant',
                            placeoffunctionality
                        )
                    );
                }
                //Existing per,new participant contact,new delegate and new/existing delegate contact
                else if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c == null &&
                    pderIdList != null &&
                    pderIdList.size() > 0 &&
                    perandPderMap.get(pe) != null &&
                    perandPderMap.get(pe).size() > 0 &&
                    perandPderMap.get(pe)[0].PPM_ID__c == null
                ) {
                    //existing delegate contact
                    if (perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null) {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'PARTICIPANT-DELEGATE',
                                'Delegate:ParticipantContact',
                                'PARTICIPANT-DELEGATE',
                                'Participant:DelegateContact',
                                placeoffunctionality
                            )
                        );
                    } else {
                        //new delegate contact
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'PARTICIPANT-DELEGATE',
                                'ParticipantContact:Delegate:DelegateContact',
                                'PARTICIPANT',
                                'Participant',
                                placeoffunctionality
                            )
                        );
                    }
                }
                //Existing per,new participant contact,existing delegate and existing/new delegate contact
                else if (
                    pe.PPMID__c != null &&
                    pe.Participant_Contact__r.PPM_ID__c == null &&
                    pderIdList != null &&
                    pderIdList.size() > 0 &&
                    perandPderMap.get(pe) != null &&
                    perandPderMap.get(pe).size() > 0 &&
                    perandPderMap.get(pe)[0].PPM_ID__c != null
                ) {
                    //existing delegate contact
                    if (perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null) {
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'PARTICIPANT',
                                'ParticipantContact',
                                'PARTICIPANT-DELEGATE',
                                'Participant:Delegate:DelegateContact',
                                placeoffunctionality
                            )
                        );
                    } else {
                        //new delegate contact
                        System.enqueueJob(
                            new UCPM_PostConsentQueueable(
                                pe,
                                perandPderMap.get(pe),
                                'Both',
                                iqviaOutreach,
                                'PARTICIPANT-DELEGATE',
                                'ParticipantContact:DelegateContact',
                                'PARTICIPANT-DELEGATE',
                                'Participant:Delegate',
                                placeoffunctionality
                            )
                        );
                    }
                }
            }
            //Patinet self consents - Existing per,existing participant contact
            else if (
                (placeoffunctionality == 'Patient Communication Preferences' ||
                placeoffunctionality == 'Patient Registration') &&
                pe.PPMID__c != null &&
                pderIdList == null
            ) {
                if (pe.Participant_Contact__r.PPM_ID__c != null) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            null,
                            'Update',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'Participant:ParticipantContact',
                            placeoffunctionality
                        )
                    );
                } else {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            perandPderMap.get(pe),
                            'Both',
                            iqviaOutreach,
                            'PARTICIPANT',
                            'ParticipantContact',
                            'PARTICIPANT',
                            'Participant',
                            placeoffunctionality
                        )
                    );
                }
            }
            //Delegate - Self consents - Existing pder, new delegate participant contact
            else if (
                (placeoffunctionality == 'Delegate Communication Preferences' ||
                placeoffunctionality == 'Delegate Registration') &&
                pe.PPMID__c != null &&
                pderIdList != null &&
                pderIdList.size() > 0 &&
                perandPderMap.get(pe) != null &&
                perandPderMap.get(pe).size() > 0 &&
                perandPderMap.get(pe)[0].PPM_ID__c != null
            ) {
                if (perandPderMap.get(pe)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null) {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            perandPderMap.get(pe),
                            'Update',
                            iqviaOutreach,
                            'DELEGATE',
                            'Delegate:DelegateContact',
                            placeoffunctionality
                        )
                    );
                } else {
                    System.enqueueJob(
                        new UCPM_PostConsentQueueable(
                            pe,
                            perandPderMap.get(pe),
                            'Both',
                            iqviaOutreach,
                            'DELEGATE',
                            'DelegateContact',
                            'DELEGATE',
                            'Delegate',
                            placeoffunctionality
                        )
                    );
                }
            }
        }
        // }
    }
    public static String requestJsonGeneration_Create(
        Participant_Enrollment__c per,
        List<Patient_Delegate_Enrollment__c> pDelEnrol,
        Boolean isIqviaOutreachEnabled,
        String conditionOperator,
        String placeoffunctionality
    ) {
        List<String> splitList = conditionOperator.split(':');
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('ParticipantData');
        gen.writeStartObject();
        // creation of delegate for existing par enrollment
        if (
            (splitList.contains('Delegate') || splitList.contains('DelegateContact')) &&
            ((!splitList.contains('Participant')) && (!splitList.contains('ParticipantContact')))
        ) {
            gen.writeStringField('studyPPMID', string.isblank(per.PPMID__c) ? ' ' : per.PPMID__c);
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(per.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : per.Participant_Contact__r.PPM_ID__c
            );
        }
        // creation of per for existing par contact
        if (splitList.contains('Participant') && (!splitList.contains('ParticipantContact'))) {
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(per.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : per.Participant_Contact__r.PPM_ID__c
            );
        }
        gen.writeStringField('sponsor', per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c);
        gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
        gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
        gen.writeStringField(
            'nctId',
            string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                ? ' '
                : per.Clinical_Trial_Profile__r.NCT_Number__c
        );
        gen.writeStringField('otSponsorId', per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c);
        gen.writeStringField('otPurposeId', per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c);
        gen.writeStringField('otCPId', ' ');
        gen.writeStringField('applicationId', per.Id);
        gen.writeDateTimeField('time', System.now());
        gen.writeStringField(
            'countryCode',
            string.isblank(per.Participant__r.Mailing_Country_Code__c)
                ? ''
                : per.Participant__r.Mailing_Country_Code__c
        );

        gen.writeFieldName('processingPurpose');
        // start processing purpose
        gen.writeStartArray();
        // Study consent start
        if (splitList.contains('Participant')) {
            gen.writeStartObject();
            gen.writeStringField('key', 'Communication-Consents');
            gen.writeBooleanField('iqviaOrg', false);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField('value', per.Permit_Mail_Email_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField('value', per.Permit_Voice_Text_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField('value', per.Permit_SMS_Text_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', per.Study_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        // Study consent end
        // IQVIA consent end

        if (
            isIqviaOutreachEnabled &&
            splitList.contains('ParticipantContact') &&
            placeoffunctionality != 'ePR'
        ) {
            gen.writeStartObject();
            gen.writeStringField('key', 'IQVIA-Outreach-Consents');
            gen.writeBooleanField('iqviaOrg', true);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        // IQVIA consent end

        gen.writeEndArray();
        // end of processing purpose
        gen.writeEndObject(); // end of participant

        //Delegates
        gen.writeFieldName('Delegates');
        //delegate start
        gen.writeStartArray();
        if (pDelEnrol != null && !pDelEnrol.isEmpty()) {
            for (Patient_Delegate_Enrollment__c pder : pDelEnrol) {
                gen.writeStartObject();
                gen.writeStringField(
                    'sponsor',
                    per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                );
                gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
                gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
                gen.writeStringField(
                    'nctId',
                    string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                        ? ' '
                        : per.Clinical_Trial_Profile__r.NCT_Number__c
                );
                gen.writeStringField(
                    'otSponsorId',
                    per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
                );
                gen.writeStringField(
                    'otPurposeId',
                    per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
                );
                gen.writeStringField('otCPId', ' ');
                gen.writeStringField('applicationId', pder.Id);
                gen.writeBooleanField('isPrimary', pder.Primary_Delegate__c ? true : false);
                gen.writeBooleanField('isActive', pder.Status__c == 'Active' ? true : false);
                gen.writeStringField(
                    'countryCode',
                    string.isblank(
                            pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                        )
                        ? ''
                        : pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                );
                gen.writeDateTimeField('time', System.now());
                gen.writeFieldName('processingPurpose');
                // prcessing start
                gen.writeStartArray();

                // Study consent start
                if (splitList.contains('Delegate')) {
                    gen.writeStartObject();
                    gen.writeStringField('key', 'Communication-Consents');
                    gen.writeBooleanField('iqviaOrg', false);
                    gen.writeFieldName('consentPurpose');

                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'email');
                    gen.writeBooleanField('value', pder.Study_Email_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'phone');
                    gen.writeBooleanField('value', pder.Study_Phone_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'sms');
                    gen.writeBooleanField('value', pder.Study_SMS_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'directMail');
                    gen.writeBooleanField('value', pder.Study_Direct_Mail_Consent__c);
                    gen.writeEndObject();
                    gen.writeEndArray();
                    gen.writeEndObject();
                }
                // Study consent end

                // IQVIA consent start
                if (
                    isIqviaOutreachEnabled &&
                    splitList.contains('DelegateContact') &&
                    placeoffunctionality != 'ePR' &&
                    (string.isblank(per.Participant__r.Email__c) ||
                    placeoffunctionality == 'Delegate Communication Preferences' ||
                    placeoffunctionality == 'Delegate Registration')
                ) {
                    gen.writeStartObject();
                    gen.writeStringField('key', 'IQVIA-Outreach-Consents');
                    gen.writeBooleanField('iqviaOrg', true);
                    gen.writeFieldName('consentPurpose');

                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'email');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'phone');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'sms');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'directMail');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c
                    );
                    gen.writeEndObject();
                    gen.writeEndArray();
                    gen.writeEndObject();
                }
                // IQVIA consent end

                gen.writeEndArray();
                // procesing end

                gen.writeEndObject();
            }
        }

        gen.writeEndArray();
        //delegat end
        gen.writeEndObject();
        String requestString = gen.getAsString();
        return requestString;
    }
    public static String requestJsonGeneration_Update(
        Participant_Enrollment__c per,
        List<Patient_Delegate_Enrollment__c> pDelEnrol,
        Boolean isIqviaOutreachEnabled,
        String conditionOperator,
        String placeoffunctionality
    ) {
        List<String> splitList = conditionOperator.split(':');
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('ParticipantData');
        gen.writeStartObject();
        gen.writeStringField('studyPPMID', string.isblank(per.PPMID__c) ? ' ' : per.PPMID__c);
        gen.writeStringField(
            'iqviaPPMID',
            string.isblank(per.Participant_Contact__r.PPM_ID__c)
                ? ' '
                : per.Participant_Contact__r.PPM_ID__c
        );
        gen.writeStringField('sponsor', per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c);
        gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
        gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
        gen.writeStringField(
            'nctId',
            string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                ? ' '
                : per.Clinical_Trial_Profile__r.NCT_Number__c
        );
        gen.writeStringField('otSponsorId', per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c);
        gen.writeStringField('otPurposeId', per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c);
        gen.writeStringField('otCPId', ' ');
        gen.writeStringField('applicationId', per.Id);
        gen.writeDateTimeField('time', System.now());
        gen.writeStringField(
            'countryCode',
            string.isblank(per.Participant__r.Mailing_Country_Code__c)
                ? ''
                : per.Participant__r.Mailing_Country_Code__c
        );

        gen.writeFieldName('processingPurpose');
        // start processing purpose
        gen.writeStartArray();

        // Study consent start
        if (splitList.contains('Participant')) {
            gen.writeStartObject();
            gen.writeStringField('key', 'Communication-Consents');
            gen.writeBooleanField('iqviaOrg', false);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField('value', per.Permit_Mail_Email_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField('value', per.Permit_Voice_Text_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField('value', per.Permit_SMS_Text_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', per.Study_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }

        // Study consent end

        // IQVIA consent end

        if (
            isIqviaOutreachEnabled &&
            splitList.contains('ParticipantContact') &&
            placeoffunctionality != 'ePR'
        ) {
            gen.writeStartObject();
            gen.writeStringField('key', 'IQVIA-Outreach-Consents');
            gen.writeBooleanField('iqviaOrg', true);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField(
                'value',
                per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c
            );
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        }
        // IQVIA consent end

        gen.writeEndArray();
        // end of processing purpose
        gen.writeEndObject(); // end of participant

        //Delegates
        gen.writeFieldName('Delegates');
        //delegate start
        gen.writeStartArray();
        if (pDelEnrol != null && !pDelEnrol.isEmpty()) {
            for (Patient_Delegate_Enrollment__c pder : pDelEnrol) {
                gen.writeStartObject();
                gen.writeStringField(
                    'studyPPMID',
                    string.isblank(pder.PPM_ID__c) ? ' ' : pder.PPM_ID__c
                );
                gen.writeStringField(
                    'iqviaPPMID',
                    string.isblank(pder.Patient_Delegate__r.Contact__r.PPM_ID__c)
                        ? ' '
                        : pder.Patient_Delegate__r.Contact__r.PPM_ID__c
                );

                gen.writeStringField(
                    'sponsor',
                    per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                );
                gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
                gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
                gen.writeStringField(
                    'nctId',
                    string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                        ? ' '
                        : per.Clinical_Trial_Profile__r.NCT_Number__c
                );
                gen.writeStringField(
                    'otSponsorId',
                    per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
                );
                gen.writeStringField(
                    'otPurposeId',
                    per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
                );
                gen.writeStringField('otCPId', ' ');
                gen.writeStringField('applicationId', pder.Id);
                gen.writeBooleanField('isPrimary', pder.Primary_Delegate__c ? true : false);
                gen.writeBooleanField('isActive', pder.Status__c == 'Active' ? true : false);
                gen.writeStringField(
                    'countryCode',
                    string.isblank(
                            pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                        )
                        ? ''
                        : pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                );
                gen.writeDateTimeField('time', System.now());
                gen.writeFieldName('processingPurpose');
                // prcessinf start
                gen.writeStartArray();

                // Study consent start
                if (splitList.contains('Delegate')) {
                    gen.writeStartObject();
                    gen.writeStringField('key', 'Communication-Consents');
                    gen.writeBooleanField('iqviaOrg', false);
                    gen.writeFieldName('consentPurpose');

                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'email');
                    gen.writeBooleanField('value', pder.Study_Email_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'phone');
                    gen.writeBooleanField('value', pder.Study_Phone_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'sms');
                    gen.writeBooleanField('value', pder.Study_SMS_Consent__c);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'directMail');
                    gen.writeBooleanField('value', pder.Study_Direct_Mail_Consent__c);
                    gen.writeEndObject();
                    gen.writeEndArray();
                    gen.writeEndObject();
                }

                // Study consent end

                // IQVIA consent start

                if (
                    isIqviaOutreachEnabled &&
                    splitList.contains('DelegateContact') &&
                    placeoffunctionality != 'ePR' &&
                    (string.isblank(per.Participant__r.Email__c) ||
                    placeoffunctionality == 'Delegate Communication Preferences' ||
                    placeoffunctionality == 'Delegate Registration')
                ) {
                    gen.writeStartObject();
                    gen.writeStringField('key', 'IQVIA-Outreach-Consents');
                    gen.writeBooleanField('iqviaOrg', true);
                    gen.writeFieldName('consentPurpose');

                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'email');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'phone');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'sms');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c
                    );
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('key', 'directMail');
                    gen.writeBooleanField(
                        'value',
                        pder.Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c
                    );
                    gen.writeEndObject();
                    gen.writeEndArray();
                    gen.writeEndObject();
                }
                // IQVIA consent end

                gen.writeEndArray();
                // procesing end

                gen.writeEndObject();
            }
        }

        gen.writeEndArray();
        //delegat end
        gen.writeEndObject();
        String requestString = gen.getAsString();
        return requestString;
    }

    @future(callout=true)
    public static void getdatafromsharingoptionspage(
        List<Id> perIdList,
        List<Id> pderIdList,
        String placeoffunctionality
    ) {
        fetchPerAndPderDetails(perIdList, pderIdList, placeoffunctionality);
    }

    @future(callout=true)
    public static void callUCPMtoPostConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        callUCPMtoSendConsents(request, accessToken, IdentityType);
    }

    @future(callout=true)
    public static void callUCPMtoupdateConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        callUCPMtoPUTConsents(request, accessToken, IdentityType);
    }

    public static void callUCPMtoSendConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        try {

            List<ResponseWrapper> responsWrap;

            List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
            List<Contact> conToUpdate = new List<Contact>();
            List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();
            List<Contact> contactToUpdate = new List<Contact>();
            List<ParticipantData> respPart = new List<ParticipantData>();
            List<Delegates> respDelg = new List<Delegates>();
            String requestString = request;
            System.debug('requestBody@@' + requestString);

            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Post_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('POST');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);

            // UPDATE DETAILS
            r.setHeader('identityType', IdentityType);
            r.setHeader('source', 'RH');
            r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
            r.setTimeout(120000);
            System.debug('###### request ' + r.getBody());
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('###### resp body  ' + resp.getBody());

            //Create IntegrationLog__c for monitoring purpose
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Create PPMID in UCPM';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            system.debug('status code' + resp.getStatusCode());
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getStatusCode());
                objIntegrationLog.Success__c = true;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
                System.debug('resp.getBody(): ' + resp.getBody());
                String s1 = resp.getBody();
                s1 = s1.replace('failed-key', 'failed_key');
                List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>) JSON.deserialize(
                    s1,
                    List<ResponseWrapper>.class
                );
                if (deserializedResponseWrapper != null) {
                    if (deserializedResponseWrapper[0].ParticipantData != null)
                        respPart = deserializedResponseWrapper[0].ParticipantData;

                    if (deserializedResponseWrapper[0].Delegates != null)
                        respDelg = deserializedResponseWrapper[0].Delegates;

                    if (!respPart.isEmpty()) {
                        for (ParticipantData partData : respPart) {
                            if (
                                partData.code == 200 &&
                                partData.ppmid != null &&
                                !partData.iqviaOrg
                            ) {
                                Participant_Enrollment__c per = new Participant_Enrollment__c();
                                per.Id = partData.applicationId;
                                per.PPMID__c = partData.ppmid;
                                per.UCPM_Status__c = 'Completed';
                                perToUpdate.add(per);
                            }
                            if (
                                partData.code == 200 &&
                                partData.ppmid != null &&
                                partData.iqviaOrg
                            ) {
                                Participant_Enrollment__c per = [
                                    SELECT Id, Participant_Contact__c
                                    FROM Participant_Enrollment__c
                                    WHERE Id = :partData.applicationId
                                ];
                                Contact con = new Contact();
                                con.Id = per.Participant_Contact__c;
                                con.PPM_ID__c = partData.ppmid;
                                con.UCPM_Status__c = 'Completed';
                                conToUpdate.add(con);
                            }
                        }
                    }
                    if (!respDelg.isEmpty()) {
                        for (Delegates delgData : respDelg) {
                            if (
                                delgData.code == 200 &&
                                delgData.ppmid != null &&
                                !delgData.iqviaOrg
                            ) {
                                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                                pder.Id = delgData.applicationId;
                                pder.PPM_ID__c = delgData.ppmid;
                                pder.UCPM_Status__c = 'Completed';
                                pderToUpdate.add(pder);
                            }
                            if (
                                delgData.code == 200 &&
                                delgData.ppmid != null &&
                                delgData.iqviaOrg
                            ) {
                                Patient_Delegate_Enrollment__c pder = [
                                    SELECT Id, Patient_Delegate__r.Contact__c
                                    FROM Patient_Delegate_Enrollment__c
                                    WHERE Id = :delgData.applicationId
                                ];
                                Contact con = new Contact();
                                con.Id = pder.Patient_Delegate__r.Contact__c;
                                con.PPM_ID__c = delgData.ppmid;
                                con.UCPM_Status__c = 'Completed';
                                conToUpdate.add(con);
                            }
                        }
                    }
                }
            } else {
                objIntegrationLog.Success__c = false;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
            }
            insert objIntegrationLog;
            if (!perToUpdate.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.EcoaEvents.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
                );

                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
                );
                database.update(perToUpdate, false);
            }
            if (!pderToUpdate.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreatePrimaryDelegateForMinor.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.UpdateDelegateConsent.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.UpdateConsentTimeStamps.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.AssignCommunityPermissionSets.class
                );
                database.update(pderToUpdate, false);
            }

            if (!conToUpdate.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdateConsentTimeStamps.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.CreateUserForCCContactHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.PopulateOverrideFields.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.CreateUserForDelegateContactHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.CreateUserForDelegateContactHandler.class
                );
                database.update(conToUpdate, false);
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Create PPMID in UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            insert objIntegrationLog;
        }
    }

    public static void callUCPMtoPUTConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
        List<Contact> conToUpdate = new List<Contact>();
        List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();
        List<Contact> contactToUpdate = new List<Contact>();
        List<ParticipantData> respPart = new List<ParticipantData>();
        List<Delegates> respDelg = new List<Delegates>();
        try {

            List<ResponseWrapper> responsWrap;
            String requestString = request;
            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Post_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('PUT');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);

            // UPDATE DETAILS
            r.setHeader('identityType', IdentityType);
            r.setHeader('source', 'RH');
            r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
            r.setTimeout(120000);
            System.debug('###### request ' + r.getBody());
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('###### resp body  ' + resp.getBody());

            //Create IntegrationLog__c for monitoring purpose
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            system.debug('status code' + resp.getStatusCode());
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getStatusCode());
                objIntegrationLog.Success__c = true;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
                List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>) JSON.deserialize(
                    resp.getBody(),
                    List<ResponseWrapper>.class
                );
                if (deserializedResponseWrapper != null) {
                    if (deserializedResponseWrapper[0].ParticipantData != null)
                        respPart = deserializedResponseWrapper[0].ParticipantData;

                    if (deserializedResponseWrapper[0].Delegates != null)
                        respDelg = deserializedResponseWrapper[0].Delegates;

                    if (!respPart.isEmpty()) {
                        for (ParticipantData partData : respPart) {
                            if (
                                partData.code == 200 &&
                                partData.ppmid != null &&
                                !partData.iqviaOrg
                            ) {
                                Participant_Enrollment__c per = new Participant_Enrollment__c();
                                per.Id = partData.applicationId;
                                per.PPMID__c = partData.ppmid;
                                perToUpdate.add(per);
                            }
                            if (
                                partData.code == 200 &&
                                partData.ppmid != null &&
                                partData.iqviaOrg
                            ) {
                                Participant_Enrollment__c per = [
                                    SELECT Id, Participant_Contact__c
                                    FROM Participant_Enrollment__c
                                    WHERE Id = :partData.applicationId
                                ];
                                Contact con = new Contact();
                                con.Id = per.Participant_Contact__c;
                                con.PPM_ID__c = partData.ppmid;
                                conToUpdate.add(con);
                            }
                        }
                    }
                    if (!respDelg.isEmpty()) {
                        for (Delegates delgData : respDelg) {
                            if (
                                delgData.code == 200 &&
                                delgData.ppmid != null &&
                                !delgData.iqviaOrg
                            ) {
                                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                                pder.Id = delgData.applicationId;
                                pder.PPM_ID__c = delgData.ppmid;
                                pderToUpdate.add(pder);
                            }
                            if (
                                delgData.code == 200 &&
                                delgData.ppmid != null &&
                                delgData.iqviaOrg
                            ) {
                                Patient_Delegate_Enrollment__c pder = [
                                    SELECT Id, Patient_Delegate__r.Contact__c
                                    FROM Patient_Delegate_Enrollment__c
                                    WHERE Id = :delgData.applicationId
                                ];
                                Contact con = new Contact();
                                con.Id = pder.Patient_Delegate__r.Contact__c;
                                con.PPM_ID__c = delgData.ppmid;
                                conToUpdate.add(con);
                            }
                        }
                    }
                }
            } else {
                objIntegrationLog.Success__c = false;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
            }
            insert objIntegrationLog;
            // update pder,per,contact
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            insert objIntegrationLog;
        }
    }

    public static ReturnWrapper callUCPMtoSaveConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        try {
            ReturnWrapper rw = new ReturnWrapper();
            List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
            List<ParticipantData> respPart = new List<ParticipantData>();
            List<Delegates> respDelg = new List<Delegates>();

            //accessToken=getAccessToken();
            //System.debug('accessToken@@'+accessToken);
            String requestString = request;
            System.debug('requestBody@@' + requestString);

            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Post_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('POST');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);

            // UPDATE DETAILS
            r.setHeader('identityType', IdentityType);
            r.setHeader('source', 'RH');
            r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
            r.setTimeout(120000);
            System.debug('###### request ' + r.getBody());
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('###### resp body  ' + resp.getBody());

            //Create IntegrationLog__c for monitoring purpose
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Create PPMID in UCPM';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            system.debug('status code' + resp.getStatusCode());
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getStatusCode());
                objIntegrationLog.Success__c = true;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
                System.debug('resp.getBody(): ' + resp.getBody());
                String s1 = resp.getBody();
                s1 = s1.replace('failed-key', 'failed_key');
                List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>) JSON.deserialize(
                    s1,
                    List<ResponseWrapper>.class
                );
                if (deserializedResponseWrapper != null) {
                    if (deserializedResponseWrapper[0].ParticipantData != null)
                        respPart = deserializedResponseWrapper[0].ParticipantData;

                    if (deserializedResponseWrapper[0].Delegates != null)
                        respDelg = deserializedResponseWrapper[0].Delegates;

                    if (!respPart.isEmpty()) {
                        for (ParticipantData partData : respPart) {
                            if (
                                partData.code == 200 &&
                                partData.ppmid != null &&
                                !partData.iqviaOrg
                            ) {
                                Participant_Enrollment__c per = new Participant_Enrollment__c();
                                per.Id = partData.applicationId;
                                per.PPMID__c = partData.ppmid;
                                per.UCPM_Status__c = 'Completed';
                                perToUpdate.add(per);
                            }
                        }
                    }
                }
            } else {
                objIntegrationLog.Success__c = false;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
            }
            if (!perToUpdate.isEmpty()) {
                rw.per = perToUpdate[0];
            }
            rw.log = objIntegrationLog;
            return rw;
        } catch (Exception e) {
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Create PPMID in UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            ReturnWrapper rw = new ReturnWrapper();
            rw.log = objIntegrationLog;
            return rw;
        }
    }

    public class ReturnWrapper {
        public Participant_Enrollment__c per;
        public IntegrationLog__c log;
    }

    public class UCPM_RequestWrapper {
        public Id perId;
        public Boolean isIqviaOutreachEnabled;
    }

    public class ResponseWrapper {
        public List<ParticipantData> ParticipantData;
        public List<Delegates> Delegates;
    }
    public class ParticipantData {
        public Integer code;
        public String status;
        public String message;
        public String transactionId;
        public String applicationId;
        public String otSponsorId;
        public String otPurposeId;
        public String ppmid;
        public String sponsor;
        public String study;
        public String failedkey;
        public String timestamp;
        public Boolean iqviaOrg;
    }
    public class Delegates {
        public Integer code;
        public String status;
        public String message;
        public String transactionId;
        public String applicationId;
        public String otSponsorId;
        public String otPurposeId;
        public String ppmid;
        public String sponsor;
        public String study;
        public String failed_key;
        public String timestamp;
        public Boolean iqviaOrg;
    }

}