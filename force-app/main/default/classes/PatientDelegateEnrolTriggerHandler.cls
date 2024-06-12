public without sharing class PatientDelegateEnrolTriggerHandler {
    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';
    public static final String PATIENT_DELEGATE_DELETED_STATUS = 'Deleted';
    public static final String PATIENT_DELEGATE_WITHDRAWN_STATUS = 'Withdrawn';

    public class CreateNewAssignmentNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            Set<Id> pdeIdSet = new set<Id>();
            for(SObject pde: newList ){
                pdeIdSet.add(pde.Id);
            }
            //createDelegateAssignmentNotification(newList);
            if (System.isFuture() || System.isBatch()) {
                createDelegateAssignmentNotification(pdeIdSet);
            }
            else{
                createDelegateAssignmentNotificationFuture(pdeIdSet);
            }
        }
    }
    public class CreateReactivatedNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDelegateReactivatedNotification(newList, (Map<Id, Patient_Delegate_Enrollment__c>) oldMap);
        }
    }
    public class UCPMStausChangeOrPrimaryChangeNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<Patient_Delegate_Enrollment__c> pdeList = newList;
            List<Patient_Delegate_Enrollment__c> eligiblePDEforUCPM = new List<Patient_Delegate_Enrollment__c>();
            Map<Id, Patient_Delegate_Enrollment__c> pdeOldMap = (Map<Id, Patient_Delegate_Enrollment__c>) oldMap;
            for (Patient_Delegate_Enrollment__c pder : [Select Id,PPM_ID__c,Participant_Enrollment__r.PPMID__c,Status__c,Primary_Delegate__c from Patient_Delegate_Enrollment__c where Id IN: pdeList ]) {
               
             if ( pder.PPM_ID__c != null && pder.Participant_Enrollment__r.PPMID__c != null && ((pder.Status__c != PATIENT_DELEGATE_ACTIVE_STATUS &&
             pdeOldMap.get(pder.Id).Status__c == PATIENT_DELEGATE_ACTIVE_STATUS)|| (pder.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
             pder.Status__c !=pdeOldMap.get(pder.Id).Status__c ) || (pder.Primary_Delegate__c != pdeOldMap.get(pder.Id).Primary_Delegate__c ) )){ 
              eligiblePDEforUCPM.add(pder);
                } 
            }          
            if (!eligiblePDEforUCPM.isEmpty() && eligiblePDEforUCPM.size()>0 ) {
            updateDelStsChangeOrPrimaryChangeNoti(eligiblePDEforUCPM); 
            }            
        }
    }
    public class SetDefaultPatientDelegateStatusHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }
    }
    public class UpdateConsentTimeStamps extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateConsentTimeStamps((List<Patient_Delegate_Enrollment__c>) newList);
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateConsentTimeStamps((List<Patient_Delegate_Enrollment__c>) newList, (Map<Id, Patient_Delegate_Enrollment__c>) oldMap);
        }
    }
    public class UpdateDelegateConsent extends TriggerHandler {
        Boolean isPortalUser = checkCurrentusrProfile();
        public override void beforeInsert(List<SObject> newList) {
            if (isPortalUser) {
                delegateConsentUpdate((List<Patient_Delegate_Enrollment__c>) newList, null);
            }
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (isPortalUser) {
                delegateConsentUpdate(
                    (List<Patient_Delegate_Enrollment__c>) newList,
                    (Map<Id, Patient_Delegate_Enrollment__c>) oldMap
                );
            }
        }
    }
    public class CreatePrimaryDelegateForMinor extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkPrimaryDelegate(newList);
        }

        public override void beforeDelete(List<SObject> newList) {
            notDeletePrimaryDelegate(newList);
        }

        
    }
    
   public class CreateJanssenNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            sendJanssenNotifications(
                (List<Patient_Delegate_Enrollment__c>) newList,
                null
            );
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendJanssenNotifications(
                (List<Patient_Delegate_Enrollment__c>) newList,
                (Map<Id, Patient_Delegate_Enrollment__c>) oldMap
            );
        }
    }
    
    public class AssignCommunityPermissionSets extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            Set<Id> pdeIdSet = new set<Id>();
            for(SObject pde: newList ){
                pdeIdSet.add(pde.Id);
            }
            
            if (!System.isFuture() && !System.isBatch()) {
                updatePermissionSetsAsync(pdeIdSet);
            }
            else{
                updatePermissionSets(pdeIdSet);
            }
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Id> pdeIdSet = new set<Id>();
            for(SObject pde: newList ){
                pdeIdSet.add(pde.Id);
            }
            
            if (!System.isFuture() && !System.isBatch()) {
                updatePermissionSetsAsync(pdeIdSet);
            }
            else{
                updatePermissionSets(pdeIdSet);
            }
        }
    }
    
    public static void sendJanssenNotifications(List<Patient_Delegate_Enrollment__c> pderecs,
    Map<Id, Patient_Delegate_Enrollment__c> oldMap){
        Set<Id> patientDelegateIds = new Set<Id>();
        Set<Id> pdeId = new Set<Id>();
        List<Patient_Delegate_Enrollment__c> activePder= new List<Patient_Delegate_Enrollment__c>();
        for(Patient_Delegate_Enrollment__c pde : pderecs){
            patientDelegateIds.add(pde.Patient_Delegate__r.Contact__c);  
            pdeId.add(pde.id);
        }
        
        List<Patient_Delegate_Enrollment__c> delegateEnrollmentrecrs = [
            SELECT Id,
            Patient_Delegate__r.Participant__r.Full_Name__c,
            Patient_Delegate__r.Id,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Contact__r.Is_First_Logon__c, 
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Patient_Delegate__r.Contact__r.Visited_Communities__c,
            Status__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Participant_Status__c,
            isInviteToPP__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id IN :pderecs AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        for(Patient_Delegate_Enrollment__c pde : delegateEnrollmentrecrs){
            patientDelegateIds.add(pde.Patient_Delegate__r.Contact__c);  
            pdeId.add(pde.id);
            
        }
        List<Participant_Enrollment__c> perList = [
            SELECT
                id,
                Participant__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Clinical_Trial_Profile__r.PPTemplate__c,
                Is_Virtual_Study_Site__c,
                Participant_Status__c,
                Participant_Contact__c,
                Participant__r.Contact__r.Visited_Communities__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Invited_To_PP_Date__c,
                Referral_Source__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN : patientDelegateIds
            AND ( Clinical_Trial_Profile__r.CommunityTemplate__c='PatientPortal' OR (Clinical_Trial_Profile__r.CommunityTemplate__c='Janssen' AND 
                Clinical_Trial_Profile__r.PPTemplate__c = 'PP 2.0'))
        ];

        Map<String,sObject> pdvsPde = new Map<String,sObject> ();   
        List<Patient_Delegate_Enrollment__c> iqviaPde = [select Id,Patient_Delegate__c, Patient_Delegate__r.Contact__c ,Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c from Patient_Delegate_Enrollment__c where 
                                                        Patient_Delegate__r.Contact__c IN :patientDelegateIds
                                                           and Id NOT IN : pdeId and  //Status__c =:PATIENT_DELEGATE_ACTIVE_STATUS and
                                                            isInviteToPP__c=true and 
                                                       (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen')];
        for(Patient_Delegate_Enrollment__c pde : iqviaPde){
            String key  = pde.Patient_Delegate__r.Contact__c+'-'+pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
        	pdvsPde.put(key,pde);
        }
        // check for template in PE's as well
        for(Participant_Enrollment__c pe : perList){
            String key  = pe.Participant_Contact__c+'-'+pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
        	pdvsPde.put(key,pe);
        }

        Set<Id> assigneeIds  = new Set<id>();
        for (Patient_Delegate_Enrollment__c pdeNew : delegateEnrollmentrecrs) 
             {
                    String visitedCommunities = pdeNew.Patient_Delegate__r.Contact__r.Visited_Communities__c;
                    Boolean checkVisitedCommunity = false;
                    if (visitedCommunities != null)
                        checkVisitedCommunity = visitedCommunities.contains('PatientPortal');
                   if(oldMap==null ||
                    (oldMap!= null && pdeNew.Status__c ==  PATIENT_DELEGATE_ACTIVE_STATUS &&
                        oldMap.get(pdeNew.Id).Status__c == PATIENT_DELEGATE_DISCONNECTED_STATUS &&
                        oldMap.get(pdeNew.Id).isInviteToPP__c == false &&
                        pdeNew.isInviteToPP__c == true )
                    ){
                    if(((  pdeNew.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c =='Janssen' 
                       && pdeNew.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0' 
                       && pdvsPde.containskey(pdeNew.Patient_Delegate__r.Contact__c + '-' +'PatientPortal') 
                       && !pdvsPde.containskey(pdeNew.Patient_Delegate__r.Contact__c+ '-' +'Janssen'))
                      ||(pdeNew.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c =='PatientPortal'
                        && pdvsPde.containskey(pdeNew.Patient_Delegate__r.Contact__c+ '-' +'Janssen')
                        &&  !pdvsPde.containskey(pdeNew.Patient_Delegate__r.Contact__c+ '-' +'PatientPortal')))
                       && !checkVisitedCommunity) {
                         assigneeIds.add(pdeNew.Patient_Delegate__r.Contact__c);
                    }
                   }
                
             	}

        if(!assigneeIds.isEmpty()){
            system.enqueueJob(new PermissionSetDeletion(assigneeIds,false));
        }
          
    }

    @TestVisible
    private static void createDelegateReactivatedNotification(
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollmentrecrs,
        Map<Id, Patient_Delegate_Enrollment__c> oldMap
    ) {
        List<Patient_Delegate_Enrollment__c> updatedpatientDelegateEnrollmentrecrs = [
            SELECT Id,
            Patient_Delegate__r.Participant__r.Full_Name__c,
            Patient_Delegate__r.Id,
            Welcome_Message_Sent__c,
            Study_Email_Consent__c,
            Study_SMS_Consent__c,
            Welcome_Message_Delivered__c,
            Patient_Delegate__r.Participant__r.Contact__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Patient_Delegate__r.Participant__r.First_Name__c,
            Patient_Delegate__r.Participant__r.Last_Name__c,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Contact__r.Is_First_Logon__c,
            Patient_Delegate__r.Participant__c,   
            Patient_Delegate__r.Participant_Delegate__r.Id,
            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Email__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Status__c,
            Participant_Enrollment__c,
            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
            Participant_Enrollment__r.Name,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Participant_Status__c,
            isInviteToPP__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id IN :patientDelegateEnrollmentrecrs AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];

        List<Patient_Delegate_Enrollment__c> activatedDelegateEnrolrecrds = new List<Patient_Delegate_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> activatedDelegateEnrolrecrdsNewAssignment = new List<Patient_Delegate_Enrollment__c>();
        Set<Id> pdIdReactivatedDupCheckSet = new set<Id>();
        Set<Id> pdIdReactivatedDupCheckSetJanssen = new set<Id>();
        Set<Id> pdIdReaddeddDupCheckSet = new set<Id>();
        Map<Id,Patient_Delegate_Enrollment__c> pdeJanssen = new Map<Id,Patient_Delegate_Enrollment__c>();
        Map<Id,Set<String>> communityTemplateForDelContIdMap = new Map<Id,Set<String>>();
        List<Patient_Delegate_Enrollment__c> withdrawnPDEORDelORNewRecrs = new List<Patient_Delegate_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> disconnectedPDErecrs = new List<Patient_Delegate_Enrollment__c>();
        for (Patient_Delegate_Enrollment__c pd : updatedpatientDelegateEnrollmentrecrs) {
            if (!communityTemplateForDelContIdMap.containsKey(pd.Patient_Delegate__r.Contact__c)){
                communityTemplateForDelContIdMap.put(pd.Patient_Delegate__r.Contact__c, new Set<String>());
            }
            if( pd.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen' && pd.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
            {
                communityTemplateForDelContIdMap.get(pd.Patient_Delegate__r.Contact__c)
                .add('PatientPortal');
            }
            else {
                communityTemplateForDelContIdMap.get(pd.Patient_Delegate__r.Contact__c)
                .add(pd.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
            } 

           
            Id delId = pd.Patient_Delegate__c;
            if (
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                oldMap.get(pd.Id).Status__c == PATIENT_DELEGATE_DISCONNECTED_STATUS &&
                oldMap.get(pd.Id).isInviteToPP__c == false &&
                pd.isInviteToPP__c == true
                ) {
                    withdrawnPDEORDelORNewRecrs.add(pd); 
                    disconnectedPDErecrs.add(pd);
                    if(!pdIdReaddeddDupCheckSet.contains(delId)){
                        pdIdReaddeddDupCheckSet.add(delId);
                        activatedDelegateEnrolrecrdsNewAssignment.add(pd);

                    }
            }
            else if (
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                oldMap.get(pd.Id).Status__c == PATIENT_DELEGATE_DISCONNECTED_STATUS
            ) {
                //When Delegate status change from Disconnected to Active - Send Access level change email.
                //Avoid creating duplicate notification records when Patient delegate is reactivated for multiple studis for same community at a time. 
                withdrawnPDEORDelORNewRecrs.add(pd); 
                    if(!pdIdReactivatedDupCheckSet.contains(delId)){
                        pdIdReactivatedDupCheckSet.add(delId);
                        activatedDelegateEnrolrecrds.add(pd);
                    }
               
            }else if(
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                ( oldMap.get(pd.Id).Status__c == PATIENT_DELEGATE_WITHDRAWN_STATUS ||
                oldMap.get(pd.Id).Status__c == PATIENT_DELEGATE_DELETED_STATUS )
            ) {
                // To make it work when del is part of Multiple studies create Alerts for each studies
                withdrawnPDEORDelORNewRecrs.add(pd);
                //When Delegate status change from Deleted/Withdrawn to Active - Send New Assignment email.
                //Avoid creating duplicate notification records when Patient delegate is readded for multiple studis  same community at a time. 
                 if(!pdIdReaddeddDupCheckSet.contains(delId)){
                    pdIdReaddeddDupCheckSet.add(delId);
                    activatedDelegateEnrolrecrdsNewAssignment.add(pd);
                }
            }
        }
        if(withdrawnPDEORDelORNewRecrs != null){
            setPDPlatformLevelAlerts(disconnectedPDErecrs);
            createPDEnrollmentAlerts(withdrawnPDEORDelORNewRecrs);
        }
        //Create Access level Change notification
        if(activatedDelegateEnrolrecrds!=null){
            createNotifications(activatedDelegateEnrolrecrds, 'DelReactivatedNotifType',communityTemplateForDelContIdMap);
        }
        //Create New Assignment notification
        if(activatedDelegateEnrolrecrdsNewAssignment!=null){
            createNotifications(activatedDelegateEnrolrecrdsNewAssignment, 'DelNewAssignNotifType',communityTemplateForDelContIdMap);
        }
        
    }
    @TestVisible
    private static void createDelegateAssignmentNotification(
        set<Id> pdeIdset
    )  {
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollRecrds = [
            SELECT Id,
            Patient_Delegate__r.Participant__r.Full_Name__c,
            Patient_Delegate__r.Id,
            Welcome_Message_Sent__c,
            Study_Email_Consent__c,
            Study_SMS_Consent__c,
            Welcome_Message_Delivered__c,
            Patient_Delegate__r.Participant__r.Contact__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Patient_Delegate__r.Participant__r.First_Name__c,
            Patient_Delegate__r.Participant__r.Last_Name__c,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Contact__r.Is_First_Logon__c,
            Patient_Delegate__r.Participant__c,   
            Patient_Delegate__r.Participant_Delegate__r.Id,
            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Email__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Status__c,
            Participant_Enrollment__c,
            Participant_Enrollment__r.Id,
            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
            Participant_Enrollment__r.Name,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Participant_Status__c,
            isInviteToPP__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id IN :pdeIdset AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        Set<Id> pdIdNewAssDupCheckSet = new set<Id>();
        Set<Id> JanssenPdIds = new set<Id>();
        List<Patient_Delegate_Enrollment__c> pdeRecrdsToProcess = New List<Patient_Delegate_Enrollment__c>();
        Map<Id,Set<String>> communityTemplateForDelContIdMap = new Map<Id,Set<String>>();
        Map<Id,Patient_Delegate_Enrollment__c> pdVsPdeJanssen = new Map<Id,Patient_Delegate_Enrollment__c>();
        
        for(Patient_Delegate_Enrollment__c pde: patientDelegateEnrollRecrds ){
            if (!communityTemplateForDelContIdMap.containsKey(pde.Patient_Delegate__r.Contact__c)){
                communityTemplateForDelContIdMap.put(pde.Patient_Delegate__r.Contact__c, new Set<String>());
            }
            
           if( pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen' && pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
            {
                communityTemplateForDelContIdMap.get(pde.Patient_Delegate__r.Contact__c)
                .add('PatientPortal');
            }
            else {
                communityTemplateForDelContIdMap.get(pde.Patient_Delegate__r.Contact__c)
                .add(pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
            } 
            Id delId = pde.Patient_Delegate__c;
            
            //Avoid creating duplicate notification records when Patient delegate is added for multiple for same community studis at a time. 
            if(!pdIdNewAssDupCheckSet.contains(delId)){
                pdIdNewAssDupCheckSet.add(delId);
                pdeRecrdsToProcess.add(pde); // Might be part of two different studies - del is same but enrollments hould be two
            }   
        }
        setPDPlatformLevelAlerts(patientDelegateEnrollRecrds);
        createPDEnrollmentAlerts(patientDelegateEnrollRecrds);
        //Create New Assignment notification
        if(pdeRecrdsToProcess!=null){
           createNotifications(pdeRecrdsToProcess, 'DelNewAssignNotifType',communityTemplateForDelContIdMap);
        }
    }
    @TestVisible
    @Future
    private static void createDelegateAssignmentNotificationFuture(
        set<Id> pdeIdset
    )  {
        createDelegateAssignmentNotification(pdeIdset);
    }

    private static List<Notification__c> createwelcomemsgSMSNotifications(
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollRecrds
    ) {
        Set<Id> participantIdSet = new Set<Id>();
        Set<Id> proccessedPlatDelCon = new Set<Id>();
        Set<Id> proccessedStudyDelCon = new Set<Id>();
        Map<Id, Patient_Delegate_Enrollment__c> patientdelegateslist = new Map<Id, Patient_Delegate_Enrollment__c>();
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Map<Id, Map<Id,Patient_Delegate_Enrollment__c>> delContIdMapOfPerIdPDEnromentMap = new Map<Id, Map<Id,Patient_Delegate_Enrollment__c>>();
        if (patientDelegateEnrollRecrds != null && !patientDelegateEnrollRecrds.isEmpty()) {
            for (Patient_Delegate_Enrollment__c pdelEnrollment : patientDelegateEnrollRecrds) {
                if (delContIdMapOfPerIdPDEnromentMap.containskey(pdelEnrollment.Patient_Delegate__r.Contact__c)){
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = delContIdMapOfPerIdPDEnromentMap.get(pdelEnrollment.Patient_Delegate__r.Contact__c);
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
                else{
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = new Map<Id, Patient_Delegate_Enrollment__c>();
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
            }
        }
        if (delContIdMapOfPerIdPDEnromentMap != null && !delContIdMapOfPerIdPDEnromentMap.isEmpty()) {
               // List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = new List<ParticipantEnrollmentPatientDelJunction__c>();
                for (Id delcon : delContIdMapOfPerIdPDEnromentMap.keyset()) { // Each del con
                    //Map<Id, Patient_Delegate_Enrollment__c> perIdPdEnrollMap = delContIdMapOfPerIdPDEnromentMap.get(delcon);
                    for (Id perId : delContIdMapOfPerIdPDEnromentMap.get(delcon).keyset()){
                        if (
                            delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Study_SMS_Consent__c && !delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Welcome_Message_Sent__c 
                            && delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c
                        ) {
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    delcon,
                                    perId,
                                    NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                                    true
                                )
                            ); 

                        }
                    }
                }
            }
        Map<Id, Contact> delconMaplst = new Map<Id, Contact>(
            [
                SELECT Id, Welcome_Message_Sent__c, Welcome_Message_Delivered__c
                FROM Contact
                WHERE ID IN :delContIdMapOfPerIdPDEnromentMap.keyset()
            ]
        );
        if (!delContIdMapOfPerIdPDEnromentMap.isEmpty() && delContIdMapOfPerIdPDEnromentMap != null) {
            for (Id delCont : delContIdMapOfPerIdPDEnromentMap.keySet()) {
                if (
                    !proccessedPlatDelCon.contains(delCont) &&
                    delconMaplst.containskey(delCont) &&
                    !delconMaplst.get(delCont).Welcome_Message_Sent__c &&
                    delContIdMapOfPerIdPDEnromentMap.get(delCont) != null
                ) {
                    proccessedPlatDelCon.add(delCont);
                        
                }
            }
        }
        
        return welcomemsgnotifications;
    }
    public static void  createPDEnrollmentAlerts(
        List<Patient_Delegate_Enrollment__c> patientDelegates
    ) {
        List<Alert__c> alertList = new List<Alert__c>();
        Map<Id,List<Participant_Enrollment__c>> pdConPerlst = new Map<Id,List<Participant_Enrollment__c>>();
        for(Patient_Delegate_Enrollment__c pde: patientDelegates){
            if(PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(
                pde.Participant_Enrollment__r.Participant_Status__c) 
              ){
                  if(pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_PP ||
                   (pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_JANSSEN && pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0'))
                  {
                      alertList.add(
                      new Alert__c(
                          Contact__c = pde.Patient_Delegate__r.Contact__c,
                          Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE_PP,
                          Record_ID__c = pde.Participant_Enrollment__c
                      )
                  );
               }
              
            else{
                alertList.add(
                    new Alert__c(
                        Contact__c = pde.Patient_Delegate__r.Contact__c,
                        Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                        Record_ID__c = pde.Participant_Enrollment__c
                    )
                ); 
            }
          }
        }
        if(!alertList.isEmpty() && alertList != null) insert alertList;
    }
    private static void createNotifications(
        List<Patient_Delegate_Enrollment__c> patientDelegates,
        String templateProperty,
        Map<Id,Set<String>> communityTemplateForDelContIdMap
    ) {
        Set<Id> participantContacts = new Set<Id>();
        Set<Id> perIds=new Set<Id>();
        List<Notification__c> notifications = new List<Notification__c>();
        Map<Id, List<Participant__c>> participantsByDelContId = new Map<Id, List<Participant__c>>();
        Map<Id, contact> delContIdDelContMap = new Map<Id, contact>();
        Boolean isJanssenTwo=false;
        if (
            templateProperty == 'DelReactivatedNotifType' ||
            templateProperty == 'DelNewAssignNotifType'
        ) {
            notifications.addAll(createwelcomemsgSMSNotifications(patientDelegates));
        }
        for(Patient_Delegate_Enrollment__c pde:patientDelegates){
            if(!participantsByDelContId.containsKey(pde.Patient_Delegate__r.Contact__c)){
                participantsByDelContId.put(pde.Patient_Delegate__r.Contact__c, new List<Participant__c>());
            }
            participantsByDelContId.get(pde.Patient_Delegate__r.Contact__c).add(pde.Patient_Delegate__r.Participant__r);
            participantContacts.add(pde.Patient_Delegate__r.Participant__r.Contact__c);
            perIds.add(pde.Participant_Enrollment__r.Id);
            contact c = new contact();
            c.Id = pde.Patient_Delegate__r.Contact__c;
            c.Is_First_Logon__c = pde.Patient_Delegate__r.Contact__r.Is_First_Logon__c;
            delContIdDelContMap.put(pde.Patient_Delegate__r.Contact__c, c);
        }
        List<Participant_Enrollment__c> enrollments = [
            SELECT Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.PPTemplate__c, Participant__c,Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Id in :perIds
        ];
        Map<Id, List<String>> communityTemplatesByParticipant = new Map<Id, List<String>>();
        for (Participant_Enrollment__c pe : enrollments){
            if (!communityTemplatesByParticipant.containsKey(pe.Participant__c)){
                communityTemplatesByParticipant.put(pe.Participant__c, new List<String>());
            }
             if( pe.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen' && pe.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
            {
                communityTemplatesByParticipant.get(pe.Participant__c)
                .add('PatientPortal');
                isJanssenTwo=true;
            }
            else {
                communityTemplatesByParticipant.get(pe.Participant__c)
                .add(pe.Clinical_Trial_Profile__r.CommunityTemplate__c);
            } 
        }

        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Assignee.ContactId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE
                (Assignee.ContactId IN :participantsByDelContId.keySet()
                OR Assignee.ContactId IN :participantContacts)
                AND PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets()
        ];
         Map<Id, Set<String>> permissionsByContact = new Map<Id, Set<String>>();
        for (PermissionSetAssignment assignment : permissionSetAssignments){
            if (!permissionsByContact.containsKey(assignment.Assignee.ContactId)){
                permissionsByContact.put(assignment.Assignee.ContactId, new Set<String>());
            }
            permissionsByContact.get(assignment.Assignee.ContactId)
                .add(assignment.PermissionSet.Name); //cid, community_pp
        }

        for (Id delCont : participantsByDelContId.keySet()){
             if (!permissionsByContact.containsKey(delCont))
                 continue;
            Set<String> delPermissions = permissionsByContact.get(delCont);
            for (Participant__c participant : participantsByDelContId.get(delCont)){
                List<CommunityTemplate> communityTemplates = new List<CommunityTemplate>();
                if (permissionsByContact.containsKey(participant.Contact__c)){
                    for (String partPerm : permissionsByContact.get(participant.Contact__c)){
                        communityTemplates.add(
                            CommunityTemplateService.getTemplateByPermissionSetName(partPerm)
                        );
                    }
                }
                else{
                    for (
                        String templateName : communityTemplatesByParticipant.get(participant.Id)
                    ){
                        communityTemplates.add(CommunityTemplateService.getTemplate(templateName));
                    }

                }              
                for (CommunityTemplate template : communityTemplates){
                    if (delPermissions.contains(template.permissionSet) && communityTemplateForDelContIdMap.get(delCont).contains(template.templateName)){
                        Contact delegateContact = delContIdDelContMap.get(delCont);
                        //If Delegate is registered then only send New Assignment email for new study assigned to delegate.
                       if(!delegateContact.Is_First_Logon__c){
                            notifications.add(
                                new Notification__c(
                                    Notification_Type__c = template.properties.get(templateProperty),
                                    Recipient__c = delCont,
                                    WhatId__c = participant.Id
                                    )
                                );
                        }
                    }
                }
            }
        }
        // Add logic For minor participants
        if (!notifications.isEmpty())
            insertNotifications(notifications);
        
        
    }

    private static void insertNotifications(List<Notification__c> notifications) {
        if (System.isFuture() || System.isBatch()) {
            insert notifications;
        } else {
            insertNotificationsAsync(JSON.serialize(notifications));
        }
    }

    @Future
    private static void insertNotificationsAsync(String notificationsJSON) {
        List<Notification__c> newNotifications = (List<Notification__c>) JSON.deserialize(
            notificationsJSON,
            List<Notification__c>.class
        );
        insert newNotifications;
    }
    
    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate_Enrollment__c> newList) {
        for (Patient_Delegate_Enrollment__c participantDelegate : newList) {
            if (participantDelegate.Status__c == null) {
                participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
            }
        }
    }

    // Create platform alerts
    public static void setPDPlatformLevelAlerts(List<Patient_Delegate_Enrollment__c> pdeIds) {
         List<Alert__c> alertList = new List<Alert__c>();
         List<Patient_Delegate_Enrollment__c> pdeList =[
             SELECT Id,
             Patient_Delegate__r.Participant__r.Full_Name__c,
             Patient_Delegate__r.Id,
             Welcome_Message_Sent__c,
             Study_Email_Consent__c,
             Study_SMS_Consent__c,
             isInviteToPP__c,
             Welcome_Message_Delivered__c,
             Patient_Delegate__r.Participant__r.Contact__c,
             Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
             Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
             Patient_Delegate__r.Participant__r.First_Name__c,
             Patient_Delegate__r.Participant__r.Last_Name__c,
             Patient_Delegate__r.Contact__c,
             Patient_Delegate__r.Participant__c,   
             Patient_Delegate__r.Participant_Delegate__r.Id,
             Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
             Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
             Patient_Delegate__r.Participant_Delegate__r.Email__c,
             Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
             Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
             Status__c,
             Participant_Enrollment__c,
             Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
             Participant_Enrollment__r.Name,
             Participant_Enrollment__r.Clinical_Trial_Profile__c,
             Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
             Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
             Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
             Participant_Enrollment__r.Participant_Status__c
             FROM Patient_Delegate_Enrollment__c
             WHERE Id IN :pdeIds
         ];
         Set<Id> delContacts = new Set<Id>();
         for(Patient_Delegate_Enrollment__c participantDelegate : pdeList){
             delContacts.add(participantDelegate.Patient_Delegate__r.Contact__c);
          }
         List<Alert__c> alerts = [
             SELECT Id, Record_ID__c, Alert_Code__c, Contact__r.Name,Viewed__c
             FROM Alert__c
             WHERE Contact__c IN : delContacts AND Is_Platform_Level__c = TRUE 
             ORDER BY CreatedDate ASC 
         ];
         for(Patient_Delegate_Enrollment__c participantDelegate : pdeList){
             if(alerts.isEmpty()){                
                 if (
                     participantDelegate.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                     CommunityTemplateService.TEMPLATE_PP || (participantDelegate.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_JANSSEN && participantDelegate.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
                 ) {
                     alertList.add(
                         new Alert__c(
                             Contact__c = participantDelegate.Patient_Delegate__r.Contact__c,
                             Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_DELEGATE_PP,
                             Record_ID__c = participantDelegate.Participant_Enrollment__r.Id,
                             Is_Platform_Level__c = true
                         )
                     );
                 } else {
                     alertList.add(
                         new Alert__c(
                             Contact__c = participantDelegate.Patient_Delegate__r.Contact__c,
                             Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_DELEGATE,
                             Record_ID__c = participantDelegate.Participant_Enrollment__r.Id,
                             Is_Platform_Level__c = true
                         )
                     );
                 } 
             }
         }
         insert alertList;
     }
 
    //This method is to make existing PDER primary as false if new primary PDER added
    public static void checkPrimaryDelegate(List<Patient_Delegate_Enrollment__c> patientDelegates) {
        List<Patient_Delegate_Enrollment__c> updatedList = new List<Patient_Delegate_Enrollment__c>();
        Set<Id> perIdList = new Set<Id>();
        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            perIdList.add(pd.Participant_Enrollment__c);
        }
        for (Patient_Delegate_Enrollment__c pderList : [
            SELECT Id, Primary_Delegate__c,Participant_Enrollment__c,Participant_Enrollment__r.Participant_Status__c 
            FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c IN :perIdList AND Primary_Delegate__c = true 
        ]) {
            for(Patient_Delegate_Enrollment__c pd: patientDelegates) { 
                if (pd.Primary_Delegate__c == true ) { 
                    pderList.Primary_Delegate__c = false;
                    updatedList.add(pderList);
                }
            }
        }
       
        update updatedList;
    }
    //This method is to prevent deleting Primary PDER
    public static void notDeletePrimaryDelegate(List<Patient_Delegate_Enrollment__c> patientDelegates) {
        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            if (pd.Primary_Delegate__c == true) {
                pd.addError('Cannot delete Primary Delegate Enrollment');
            }
        }
    }

    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Patient_Delegate_Enrollment__c> newList) {
        for (Patient_Delegate_Enrollment__c pder : newList) {
            
            pder.Study_SMS_Consent_Time__c = (pder.Study_SMS_Consent__c	
                                             ? Datetime.now()
                                             : null);
            pder.Study_Pre_recorded_Calls_Consent_Time__c = (pder.Study_Pre_recorded_Voice_Consent__c
                                                            ? Datetime.now()
                                                            : null);
            pder.Study_Storage_Consent_Time__c = (pder.Study_info_storage_consent__c
                                                    ? Datetime.now()
                                                    : null);
            pder.Study_Phone_Consent_Time__c = (pder.Study_Phone_Consent__c
                                               ? Datetime.now()
                                               : null);
            pder.Study_Email_Consent_Time__c = (pder.Study_Email_Consent__c
                                               ? Datetime.now()
                                               : null);
            pder.Study_Direct_Mail_Consent_Time__c = (pder.Study_Direct_Mail_Consent__c
                                                     ? Datetime.now()
                                                     : null);
            pder.Study_Assisted_Dialing_Consent_Time__c = (pder.Study_Assisted_Dialing_Consent__c
                                                          ? Datetime.now()
                                                          : null);
            pder.Study_Artificial_Voice_Consent_Time__c = (pder.Study_Artificial_Voice_Consent__c
                                                          ? Datetime.now()
                                                          : null);
        }
    }

    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Patient_Delegate_Enrollment__c> newList, Map<Id, Patient_Delegate_Enrollment__c> oldMap) {
        for (Patient_Delegate_Enrollment__c pder : newList) {
            Patient_Delegate_Enrollment__c oldPder = oldMap.get(pder.Id);
           
            
            if (
                pder.Study_SMS_Consent__c != oldPder.Study_SMS_Consent__c
            ) {
                pder.Study_SMS_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Pre_recorded_Voice_Consent__c !=
                oldPder.Study_Pre_recorded_Voice_Consent__c
            ) {
                pder.Study_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_info_storage_consent__c !=
                oldPder.Study_info_storage_consent__c
            ) {
                pder.Study_Storage_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Phone_Consent__c !=
                oldPder.Study_Phone_Consent__c
            ) {
                pder.Study_Phone_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Email_Consent__c !=
                oldPder.Study_Email_Consent__c
            ) {
                pder.Study_Email_Consent_Time__c = Datetime.now();
            }
            if (pder.Study_Direct_Mail_Consent__c != oldPder.Study_Direct_Mail_Consent__c) {
                pder.Study_Direct_Mail_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Assisted_Dialing_Consent__c !=
                oldPder.Study_Assisted_Dialing_Consent__c
            ) {
                pder.Study_Assisted_Dialing_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Artificial_Voice_Consent__c !=
                oldPder.Study_Artificial_Voice_Consent__c
            ) {
                pder.Study_Artificial_Voice_Consent_Time__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void delegateConsentUpdate(
        List<Patient_Delegate_Enrollment__c> newList,
        Map<Id, Patient_Delegate_Enrollment__c> oldMap
    ) {
        for (Patient_Delegate_Enrollment__c pdNew : newList) {
            if (oldMap == null) {
                pdNew.Study_Assisted_Dialing_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
                pdNew.Study_Artificial_Voice_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
                pdNew.Study_Pre_recorded_Voice_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
            } else {
                Patient_Delegate_Enrollment__c pdOld = oldMap.get(pdNew.Id);
                if (
                    pdNew.Study_Phone_Consent__c !=
                    pdOld.Study_Phone_Consent__c &&
                    pdNew.Study_Phone_Consent__c
                ) {
                    // check 3 checkboxes
                    pdNew.Study_Assisted_Dialing_Consent__c = true;
                    pdNew.Study_Artificial_Voice_Consent__c = true;
                    pdNew.Study_Pre_recorded_Voice_Consent__c = true;
                } else if (
                    pdNew.Study_Phone_Consent__c !=
                    pdOld.Study_Phone_Consent__c &&
                    !pdNew.Study_Phone_Consent__c
                ) {
                    // uncheck 3 checkboxes
                    pdNew.Study_Assisted_Dialing_Consent__c = false;
                    pdNew.Study_Artificial_Voice_Consent__c = false;
                    pdNew.Study_Pre_recorded_Voice_Consent__c = false;
                }
            }
        }
    }

    public static List<Profile> currentUserProfile;
    public static boolean checkCurrentusrProfile() {
        List<Profile> profiles;
        if(currentUserProfile==null){
            Id profileId = userinfo.getProfileId();
            currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        }
        profiles = currentUserProfile;
        if (profiles != null && !profiles.isEmpty()) {
            String profileName = profiles[0].Name;
            if (profileName == System.Label.PortalUserProfile) {
                return true;
            } else {
                return false;
            }
        }else{
            return false;
        }
    }

    @Future
    private static void updatePermissionSetsAsync(Set<Id> pdeIdSet) {
        updatePermissionSets(pdeIdSet);
    }

    //This Method will update the permission set to the patient Delegate.
    private static void updatePermissionSets(Set<Id> pdeIdSet) {
        List<Patient_Delegate_Enrollment__c> pdeList = [select id,Patient_Delegate__r.Participant__r.Contact__c,Patient_Delegate__r.Contact__c,Patient_Delegate__r.Participant__c,Participant_Enrollment__r.Id,Participant_Enrollment__r.Participant__c,Participant_Enrollment__r.Participant_Contact__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.Id,Participant_Enrollment__r.Clinical_Trial_Profile__r.ShortCommunityName__c,Participant_Enrollment__r.Participant_Status__c
                                                  from Patient_Delegate_Enrollment__c where id in: pdeIdSet  and Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS /*and Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c NOT IN :CommunityModeService.rhSponsorsByCommunity.keySet() */
                                                  and Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c != 'Virtual' and Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c != 'Hybrid'
                                                  and  Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                                                  and Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c = FALSE
                                                  and Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE]; 

        Set<Id> contactIds = new Set<Id>();
        Set<Id> perIds = new Set<Id>();
        List<Id> delegatedContacts = new List<Id>();
        Set<Id> allDelegatedParticipantIds = new Set<Id>();
        Map<Id, String> mapPERToShortCommName=new Map<Id,String>();
        Map<String, String> mapShortCommNameToPermissName=new map<String,String>();
        Map<String,Id> mapStudyContactToDel=new Map<String,Id>();//StudyId+contactId is key
        set<String> permissionNames=new Set<String>();
        Map<String,Id> permissionNameToId=new Map<String,Id>();
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        for (Patient_Delegate_Enrollment__c pde : pdeList){
            //contactIds.add(pde.Patient_Delegate__r.Contact__c);
            //perIds.add(pde.Participant_Enrollment__c);pde.
            
            String keys=pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.Id+'~'+pde.Participant_Enrollment__r.Participant_Contact__c;
            mapStudyContactToDel.put(keys,pde.Patient_Delegate__r.Contact__c);  
            allDelegatedParticipantIds.add(pde.Patient_Delegate__r.Participant__c);
            delegatedContacts.add(pde.Patient_Delegate__r.Participant__r.Contact__c);                                          
            contactIds.add(pde.Patient_Delegate__r.Contact__c);
            mapPERToShortCommName.put(pde.Participant_Enrollment__r.Id,pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
        }
        for(Community_Template__mdt commTemp:[SELECT
                Id,
                DeveloperName,
                Community_Name__c,
                Label,
                Permission_Set_Developer_Name__c,
                ShortCommunityName__c,Community_Template__c
                                              FROM Community_Template__mdt]){
                       mapShortCommNameToPermissName.put(commTemp.Community_Template__c,commTemp.Permission_Set_Developer_Name__c) ;
                         permissionNames.add(commTemp.Permission_Set_Developer_Name__c);                         
           }
        for(PermissionSet  pp:[select id,Name from PermissionSet where name in:permissionNames]){
            permissionNameToId.put(pp.Name,pp.Id);
        }
        for (Patient_Delegate_Enrollment__c pde : pdeList){
            Set<String> psaNames=new set<String>();
            Id ContactId=pde.Patient_Delegate__r.Contact__c;
            String PerId=pde.Participant_Enrollment__r.Id;
            String shortCommTemp=mapPERToShortCommName.get(PerId);
            String permissionName = '';
            if( pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen' && pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
            {
                permissionName = mapShortCommNameToPermissName.get('PatientPortal');
            }
            else {
                 permissionName=mapShortCommNameToPermissName.get(shortCommTemp);
            } 
            psaNames.add(permissionName);
            Id permissionId=permissionNameToId.get(permissionName);
            actionAssignContactPermissions.addPermissions(ContactId,psaNames);
        }
        //System.debug('XXX_ACTION: ' + JSON.serializePretty(actionAssignContactPermissions));
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
        /*System.debug('CONTACTS FOR UPDATE PERMISSIONS:' + contactIds);
        //PatientDelegateEnrollmentService.updatePermissionSets(contactIds, perIds);
        Map<Id, Set<String>> participantPermissions = new Map<Id, Set<String>>();
        for(Patient_Delegate_Enrollment__c pde :pdeList){
            Set<String> permissions = participantPermissions.get(pde.Patient_Delegate__r.Participant__c);
            if (permissions == null)
                permissions = new Set<String>();
            permissions.add(CommunityTemplateService.getTemplate(pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
            participantPermissions.put(pde.Patient_Delegate__r.Participant__c, permissions);
        }
        Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();*/
        
    }
    
    @TestVisible
    private static void updateDelStsChangeOrPrimaryChangeNoti(
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollmentrecords
    )  {
        JSONGenerator gen = JSON.createGenerator(false);            
            //Data prep for API callout                      
            gen.writeStartArray();
            for (Patient_Delegate_Enrollment__c pd : patientDelegateEnrollmentrecords) {
                gen.writeStartObject();
                    gen.writeStringField('PPMID', pd.PPM_ID__c);
                    gen.writeStringField('ParticipantPpmid', pd.Participant_Enrollment__r.PPMID__c);
                    if (pd.Status__c != null) {
                        if(pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS){
                            gen.writeBooleanField('IsActive', TRUE);
                        }
                        else{
                            gen.writeBooleanField('IsActive', FALSE);
                        }                           
                    } else {
                        gen.writeStringField('IsActive', '');
                    }
                    if (pd.Primary_Delegate__c != null) {
                        if(pd.Primary_Delegate__c == TRUE){
                            gen.writeBooleanField('IsPrimary', TRUE);
                        }
                        else{
                            gen.writeBooleanField('IsPrimary', FALSE);
                        }
                    } else {
                        gen.writeStringField('IsPrimary', '');
                    }
                    gen.writeEndObject();               
            }
            gen.writeEndArray();

            String requestString;
            requestString = gen.getAsString();
            callUCPMtoUpdateStatusorPrimary(requestString);
    }
    @future(callout=true)
    public static void callUCPMtoUpdateStatusorPrimary(
           String requestString
    ){
        String accessToken;
        String actionType ='DELEGATE';
        accessToken = MulesoftIntegrationApi.getAccessTokenIfValid(
            'Mulesoft Access Token UCPM'
        );
        MulesoftToken__c setting = MulesoftToken__c.getInstance(
            'Mulesoft Access Token UCPM'
        );
        Boolean saveAccessToken = false;
        MulesoftIntegrationApi.ResponseWrapper tokenWrap = new MulesoftIntegrationApi.ResponseWrapper();
        if (accessToken == null) {
            tokenWrap = MulesoftIntegrationApi.generateAccessTokenWithoutSave(
            setting
            );
            accessToken = tokenWrap.access_token;
            saveAccessToken = true;
        }

        DateTime dt = DateTime.now();

         //Integration log generation 
        IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
        objIntegrationLog.Request_Body__c = requestString;
        objIntegrationLog.Request_Time__c = dt;
        objIntegrationLog.Request_Type__c = 'UCPM_UpdateStatusorPrimary';
        objIntegrationLog.Function_Name__c = 'UCPM_UpdateStatusorPrimary';
        objIntegrationLog.Http_Method__c = 'POST';

        //Call Mulesoft-UCPM API for consents
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint('callout:UCPM_UpdateStatusorPrimary');
        r.setHeader('Content-Type', 'application/json;charset=UTF-8');
        r.setTimeout(120000);
        r.setMethod('POST');
        r.setHeader('Authorization', 'Bearer ' + accessToken);
        r.setbody(requestString);
        r.setHeader('actionType', actionType);
        r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());

        HTTPResponse resp;
        try{
            resp = h.send(r);
            objIntegrationLog.Response_Body__c = resp.getBody();
            objIntegrationLog.Response_Status__c = resp.getStatus();
            objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

            if (resp.getStatusCode() == 200) {
                objIntegrationLog.Success__c = true;
            }
            else {
                objIntegrationLog.Success__c = false;
            }
            insert objIntegrationLog;
             if (saveAccessToken) {
                MulesoftIntegrationApi.saveAccessToken(
                setting,
                tokenWrap.access_token,
                tokenWrap.expires_in
                );
             }
        }
        catch(exception e){
             objIntegrationLog.Response_Body__c = e.getMessage();
             objIntegrationLog.Success__c = false;
             insert objIntegrationLog;
        }

        
    }

}