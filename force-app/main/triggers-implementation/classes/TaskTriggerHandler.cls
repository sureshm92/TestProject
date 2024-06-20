/**
 * Created by Leonid Bartenev
 */

public without sharing class TaskTriggerHandler {
    public class applicationException extends Exception {}
    public static Map<Id, Boolean> surveyInvitationNewPPMap = new Map<Id, Boolean>();
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckTaskFieldsWithTaskCodeHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkTaskFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkTaskFields(newList);
        }
    }

    public class SendImmediateEmailsForTaskCodeHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            processSendImmediateEmails(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void checkTaskFields(List<Task> newList) {
        Map<String, Task_Catalog__mdt> cardsMap;
        if (!Test.isRunningTest()) {
            cardsMap = getCardsMap(newList);
        } else {
            cardsMap = getCardsMapForTestClass();
        }
        //Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(newList);
        List<Task> checkedTasks = new List<Task>();
        for (Task task : newList) {
            if (task.Task_Code__c == null)
                continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null) {
                task.Task_Code__c.addError(
                    'Task Catalog Card: ' +
                    task.Task_Code__c +
                    ' not found in catalog'
                );
                continue;
            }
            if (card.Source_Object_Type__c == null && card.Parameters__c != null) {
                task.addError(
                    'Source Object Type can not be null in Task Catalog: ' + card.DeveloperName
                );
                continue;
            }
            SObjectType sourceObjectType = Schema.getGlobalDescribe()
                .get(card.Source_Object_Type__c);
            if (sourceObjectType == null && card.Parameters__c != null) {
                task.addError(
                    'Wrong Source Object Type in Task Catalog ' +
                    card.DeveloperName +
                    ': ' +
                    card.Source_Object_Type__c
                );
                continue;
            }
            String errorsInParameters = CatalogParametersHelper.getErrorInParameters(
                sourceObjectType,
                card.Parameters__c
            );
            if (errorsInParameters != null) {
                task.addError(
                    'Task Catalog: ' +
                    card.DeveloperName +
                    '; Parameters error: ' +
                    errorsInParameters
                );
                continue;
            }

            Id whatId = task.WhatId;
            if (whatId == null) {
                whatId = task.Survey_Invitation__c;
            }
            if (whatId == null && card.Parameters__c != null) {
                task.WhatId.addError('What Id can not be null');
                continue;
            }
            Id recId;
            if (task.WhatId != null) {
                try {
                    recId = task.WhatId;
                    if (recId.getSobjectType() != sourceObjectType) {
                        task.WhatId.addError('Wrong Related To SObject Type');
                        continue;
                    }
                } catch (Exception e) {
                    task.WhatId.addError('Wrong WhatId: ' + task.WhatId);
                    continue;
                }
            }
            checkedTasks.add(task);
        }
    }

    @TestVisible
    private static void processSendImmediateEmails(List<Task> tasks) {
        Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(tasks);
        List<Notification__c> notifications = new List<Notification__c>();
        Set<Notification__c> deDupeNotifications = new Set<Notification__c>();
        List<Id> allContactsIds = new List<Id>();
        Map<Id,List<Task>> allPeIds = new Map<Id,List<Task>>();
        set<String> conWithPdeRecrd = new set<String>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> contactWithoutUser = new Set<Id>();
        // set to hold all tasks whose onwers are minor participants
        Set<Id> tasksWithoutUser = new Set<Id>();
        List<Task> tasksWithOwner = [
            SELECT
                OwnerId,
                Task_Code__c,
                Task_Type__c,
                Survey_Invitation__c,
                Survey_Invitation__r.Participant_Enrollment__c,
                Visible_For__c,
                WhatId,
                InitialTaskNotification__c,
                WhoId,
                Start_Date__c,
                Action_URL__c,
                Owner_Contact__c,
                Community_Template_Name__c
            FROM Task
            WHERE Id IN :tasks
        ];
        Set<Id> receipientIdset = new Set<Id>();
        /* If the task is created for user without email, owner_contact  is present*/
        for (Task t : tasksWithOwner) {
            if (t.Owner_Contact__c == null) {
                ownerIds.add(t.OwnerId);
            } else {
                /*Changed for minor participants to send notifications to delegates as well */
                contactWithoutUser.add(t.Owner_Contact__c);
                tasksWithoutUser.add(t.Id);
            }
            //allContactsIds.add(t.WhoId);
            //PEH-10344 create notif for delegate associated with study only(for study level tasks only)
            if (t.whatId?.getSObjectType().getDescribe().getName() == 'Participant_Enrollment__c')
            {
                if (!allPeIds.containsKey(t.whatId)) {
                    allPeIds.put(t.whatId, new List<Task>());
                }
                allPeIds.get(t.whatId).add(t); 
                receipientIdset.add(t.WhoId);
            }
            else if(t.Task_Type__c == 'Survey' ){
                if (!allPeIds.containsKey(t.Survey_Invitation__r.Participant_Enrollment__c)) {
                    allPeIds.put(t.Survey_Invitation__r.Participant_Enrollment__c, new List<Task>());
                }
                allPeIds.get(t.Survey_Invitation__r.Participant_Enrollment__c).add(t);
                receipientIdset.add(t.WhoId);
            }
            else{
                allContactsIds.add(t.WhoId);
            }
        }
        Map<Id, List<Id>> delConIdsByPACon = new Map<Id, List<Id>>();
        if (allPeIds.size() > 0)
        {
            delConIdsByPACon = PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
                new List<Id>(allPeIds.keySet()),true
            );
        }else{
            delConIdsByPACon = PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
                allContactsIds,false
            );
        }
        for (Id paKey : delConIdsByPACon.keySet())
            allContactsIds.addAll(delConIdsByPACon.get(paKey)); 
        Map<Id, List<Contact>> delegatesByPAContact = new Map<Id, List<Contact>>();
        Map<Id, List<Patient_Delegate_Enrollment__c>> perIdPdeMap = new Map<Id, List<Patient_Delegate_Enrollment__c>>();
        if (allContactsIds.size() > 0) {
            Map<Id, Contact> contactsMap = new Map<Id, Contact>(
                [
                    SELECT Id, Participant_Opt_In_Status_Emails__c
                    FROM Contact
                    WHERE Id IN :allContactsIds
                ]
            );
            for (Id paKey : delConIdsByPACon.keySet()) { 
                List<Contact> delegateContacts = new List<Contact>();
                for (Id delId : delConIdsByPACon.get(paKey)) 
                    delegateContacts.add(contactsMap.get(delId));

                delegatesByPAContact.put(paKey, delegateContacts);
            }
        }
        Map<Id, User> usersByIds = new Map<Id, User>(
            [
                SELECT
                    Id,
                    ContactId,
                    Contact.Participant_Opt_In_Status_Emails__c,
                    Contact.UserCommunityIsDelegate__c
                FROM User
                WHERE Id IN :ownerIds AND IsActive = TRUE
            ]
        );
        List<Id> partContactsIds = new List<Id>();
        for (Id usId : usersByIds.keySet()) {
            partContactsIds.add(usersByIds.get(usId).ContactId);
        }
        //Adding contacts without user to same list
        partContactsIds.addAll(contactWithoutUser);
        List<Patient_Delegate_Enrollment__c> patientDelegates = new List<Patient_Delegate_Enrollment__c>(); 
        if (allPeIds.size() > 0){
            patientDelegates = [
            SELECT
                Id,
                Participant_Enrollment__c,
                Patient_Delegate__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Name,
                Status__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c,
                Participant_Enrollment__r.study__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c IN : allPeIds.keySet() AND Status__c = 'Active' 
            ];
            for(Patient_Delegate_Enrollment__c pde : patientDelegates){
                if(receipientIdset.contains(pde.Patient_Delegate__r.contact__c)){
                    conWithPdeRecrd.add(pde.Patient_Delegate__r.contact__c+'-'+pde.Participant_Enrollment__c);
                }
            }
        }else{
            patientDelegates = [
            SELECT
                Id,
                Participant_Enrollment__c,
                Patient_Delegate__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Name,
                Status__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c,
                Participant_Enrollment__r.study__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__r.Participant__r.Contact__c IN : partContactsIds AND Status__c = 'Active' 
        ];
        }
        Map<Id, List<Id>> delegatesCntByPartCnt = new Map<Id, List<Id>>();
        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            if(!perIdPdeMap.containsKey(pd.Participant_Enrollment__c)){
               perIdPdeMap.put(pd.Participant_Enrollment__c,new List<Patient_Delegate_Enrollment__c>()); 
            }
            perIdPdeMap.get(pd.Participant_Enrollment__c).add(pd);
            if (!delegatesCntByPartCnt.containsKey(pd.Patient_Delegate__r.Participant__r.Contact__c)) {
                delegatesCntByPartCnt.put(pd.Patient_Delegate__r.Participant__r.Contact__c, new List<Id>());
            }
            delegatesCntByPartCnt.get(pd.Patient_Delegate__r.Participant__r.Contact__c).add(pd.Patient_Delegate__r.Contact__c);
        }
        
        Map<String, Object> params = new Map<String, Object>(); //For flow passing variables
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Date> taskDt = new Map<Id,Date>();
        Map<Id,Notification__c> lstNotification = new Map<Id,Notification__c>();
        Map<Id,Notification__c> finalLstNotification = new Map<Id,Notification__c>();
        Set<Notification__c> newdeDupeNotifications = new Set<Notification__c>();
        
        for (Task task : tasksWithOwner) {
           if (task.Task_Code__c != null ) {
                Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
                if (card != null && card.Immediate_Email_Template__c != null) {
                    Id whatId = task.WhatId;
                    Id whatIdDelegate;
                    if (whatId == null&& task.Task_Type__c == TaskService.TASK_TYPE_SURVEY) {
                        whatId = task.Survey_Invitation__c;
                        whatIdDelegate = task.Survey_Invitation__r.Participant_Enrollment__c	;
                        }
                    if (card.Immediate_Notification_Type__c != null) {
                        if (
                            task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER) &&
                            usersByIds.containskey(task.OwnerId) &&
                            !tasksWithoutUser.contains(task.Id)
                        ) {
                           if(task.Task_Type__c == TaskService.TASK_TYPE_SURVEY){
                                notifications.add(
                                new Notification__c(
                                    Recipient__c = usersByIds.get(task.OwnerId).ContactId,
                                    WhatId__c = whatId,
                                    Notification_Type__c = card.Immediate_Notification_Type__c,
                                    RemindUsing__c = 'Email', 
                                    IsDelegate__c = conWithPdeRecrd.contains(usersByIds.get(task.OwnerId).ContactId+'-'+whatIdDelegate) ? true : false
                                )
                            );
                            }
                            else{
                            notifications.add(
                                new Notification__c(
                                    Recipient__c = usersByIds.get(task.OwnerId).ContactId,
                                    WhatId__c = whatId,
                                    Notification_Type__c = card.Immediate_Notification_Type__c,
                                    RemindUsing__c = 'Email',
                                    IsDelegate__c = conWithPdeRecrd.contains(usersByIds.get(task.OwnerId).ContactId+'-'+task.whatId) ? true : false
                                )
                            );
                        }
                        }
                        if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                             List<Contact> delegates = delegatesByPAContact.containskey(task.WhoId)
                             ? delegatesByPAContact.get(task.WhoId) : null;
                            if(patientDelegates != null && !patientDelegates.isEmpty()){
                                List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
                                if(task.Survey_Invitation__c != null){
                                     pdEnrollments = perIdPdeMap.containsKey(task.Survey_Invitation__r.Participant_Enrollment__c) 
                                            ? perIdPdeMap.get(task.Survey_Invitation__r.Participant_Enrollment__c) : null;
                                }
                                if(pdEnrollments != null && !pdEnrollments.isEmpty()){
                                    for(Patient_Delegate_Enrollment__c pde:pdEnrollments){
                                        notifications.add(
                                            new Notification__c(
                                                Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                                IsDelegate__c = true,
                                                WhatId__c = whatId,
                                                Notification_Type__c = card.Immediate_Notification_Type__c,
                                                RemindUsing__c = 'Email'
                                            )
                                        );
                                    }
                                }
                            }else{
                                if (delegates != null && !delegates.isEmpty()) {
                                    for (Contact delContact : delegates)
                                    {
                                        notifications.add(
                                            new Notification__c(
                                                Recipient__c = delContact.Id,
                                                IsDelegate__c = true,
                                                WhatId__c = whatId,
                                                Notification_Type__c = card.Immediate_Notification_Type__c,
                                                RemindUsing__c = 'Email'
                                            )
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
                else if(task.Action_URL__c != null && task.Task_Code__c == TaskService.TASK_CODE_ECOA_TASK && (task.Community_Template_Name__c == CommunityTemplateService.TEMPLATE_PP || task.Community_Template_Name__c == CommunityTemplateService.TEMPLATE_JANSSEN)){
                    Id whatId = task.WhatId;
                    //Start
                    if (
                            task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER) &&
                            !tasksWithoutUser.contains(task.Id)
                        ) {
                            notifications.add(
                                new Notification__c(
                                    Recipient__c = usersByIds.get(task.OwnerId).ContactId,
                                    WhatId__c = task.Id,
                                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ACTIVATE_ECOA_TASK_INSTANT_TYPE,
                                    RemindUsing__c = 'Email',
                                    IsDelegate__c = conWithPdeRecrd.contains(usersByIds.get(task.OwnerId).ContactId+'-'+task.whatId) ? true : false
                                )
                            );
                        }
                        if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                            List<Contact> delegates = delegatesByPAContact.containskey(task.WhoId)
                            ? delegatesByPAContact.get(task.WhoId)
                            : null;
                            List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
                            pdEnrollments = perIdPdeMap.containsKey(task.WhatId) 
                                                    ? perIdPdeMap.get(task.WhatId) : null;
                            if(pdEnrollments != null && !pdEnrollments.isEmpty()){
                                for(Patient_Delegate_Enrollment__c pde:pdEnrollments){
                                    deDupeNotifications.add(new Notification__c(
                                            Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                            WhatId__c = task.Id,
                                            IsDelegate__c = true,
                                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ACTIVATE_ECOA_TASK_INSTANT_TYPE,
                                            StartDate__c = task.Start_Date__c,
                                            RemindUsing__c = 'Email'
                                        ));
                                }
                            }        
                        }
                    //End
                }
            }
            if (
                task.InitialTaskNotification__c && task.Task_Type__c == TaskService.TASK_TYPE_ECOA
            ) {
                if (
                    task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER) &&
                    !tasksWithoutUser.contains(task.Id)
                ) {
                    notifications.add(
                        new Notification__c(
                            Recipient__c = task.WhoId,
                            Task_Id__c = task.Id,
                            WhatId__c = task.Id,
                            Notification_Type__c = 'Message_To_PT_Ecoa_Task_Instant_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email',
                            IsDelegate__c = conWithPdeRecrd.contains(task.WhoId+'-'+task.whatId) ? true : false
                        )
                    );
                }
                if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                    List<Contact> delegates = delegatesByPAContact.containskey(task.WhoId)
                        ? delegatesByPAContact.get(task.WhoId)
                        : null;
                        List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
                        pdEnrollments = perIdPdeMap.containsKey(task.WhatId) 
                                                ? perIdPdeMap.get(task.WhatId) : null;
                        if(pdEnrollments != null && !pdEnrollments.isEmpty()){
                            for(Patient_Delegate_Enrollment__c pde:pdEnrollments){
                                /** deDupeNotifications.add(new Notification__c(
                                        Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                        WhatId__c = task.Id,
                                        IsDelegate__c = true,
                                        Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                        StartDate__c = task.Start_Date__c,
                                        RemindUsing__c = 'Email'
                                    )); **/
                                     newdeDupeNotifications.add(new Notification__c(
                                        Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                        WhatId__c = task.Id,
                                        IsDelegate__c = true,
                                        Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                        StartDate__c = task.Start_Date__c,
                                        RemindUsing__c = 'Email'
                                    )); 
                                    
                            lstNotification.put(task.Id,new Notification__c(
                            Recipient__c = pde.Patient_Delegate__r.Contact__c,
                            WhatId__c = task.Id,
                            IsDelegate__c = true,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email'
                            ));
                            contactIds.add(pde.Patient_Delegate__r.Contact__c); 
                            taskDt.put(pde.Patient_Delegate__r.Contact__c,task.Start_Date__c); 
                            }
                        }
                }
            }
            if (
                task.InitialTaskNotification__c &&
                task.Task_Type__c == TaskService.TASK_TYPE_NOT_SELECTED
            ) {
                if (
                    task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER) &&
                    !tasksWithoutUser.contains(task.Id) //added check to prevent notifications from being created for minors
                ) {
                    /** deDupeNotifications.add(
                        new Notification__c(
                            Recipient__c = task.WhoId,
                            WhatId__c = task.Id,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email',
                            IsDelegate__c = conWithPdeRecrd.contains(task.WhoId+'-'+task.whatId) ? true : false

                        )
                    );  **/
                      newdeDupeNotifications.add(
                            new Notification__c(
                            Recipient__c = task.WhoId,
                            WhatId__c = task.Id,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email',
                            IsDelegate__c = conWithPdeRecrd.contains(task.WhoId+'-'+task.whatId) ? true : false
                        )
                        );  
                    lstNotification.put(task.Id,new Notification__c(
                            Recipient__c = task.WhoId,
                            WhatId__c = task.Id,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email',
                            IsDelegate__c = conWithPdeRecrd.contains(task.WhoId+'-'+task.whatId) ? true : false

                        ));
                    contactIds.add(task.WhoId); 
                    taskDt.put(task.WhoId,task.Start_Date__c); 
                }
                if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                    List<Contact> delegates = delegatesByPAContact.containskey(task.WhoId)
                        ? delegatesByPAContact.get(task.WhoId)
                        : null;
                    List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
                    pdEnrollments = perIdPdeMap.containsKey(task.WhatId) 
                                            ? perIdPdeMap.get(task.WhatId) : null;
                    if(pdEnrollments != null && !pdEnrollments.isEmpty()){
                        for(Patient_Delegate_Enrollment__c pde:pdEnrollments){
                            
                            /**deDupeNotifications.add(new Notification__c(
                                    Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                    WhatId__c = task.Id,
                                    IsDelegate__c = true,
                                    Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                    StartDate__c = task.Start_Date__c,
                                    RemindUsing__c = 'Email'
                                )); **/
                                    newdeDupeNotifications.add(new Notification__c(
                                    Recipient__c = pde.Patient_Delegate__r.Contact__c,
                                    WhatId__c = task.Id,
                                    IsDelegate__c = true,
                                    Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                    StartDate__c = task.Start_Date__c,
                                    RemindUsing__c = 'Email'
                                )); 
                                
                            lstNotification.put(task.Id,new Notification__c(
                            Recipient__c = pde.Patient_Delegate__r.Contact__c,
                            WhatId__c = task.Id,
                            IsDelegate__c = true,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email'
                            ));
                            contactIds.add(pde.Patient_Delegate__r.Contact__c); 
                            taskDt.put(pde.Patient_Delegate__r.Contact__c,task.Start_Date__c); 
                                
                                
                        }
                    }
                    
                    else if (delegates != null && !delegates.isEmpty()) {
                        for (Contact delContact : delegates) {
                            /** deDupeNotifications.add(
                                new Notification__c(
                                    Recipient__c = delContact.Id,
                                    WhatId__c = task.Id,
                                    IsDelegate__c = true,
                                    Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                    StartDate__c = task.Start_Date__c,
                                    RemindUsing__c = 'Email'
                                )
                            ); **/
                              newdeDupeNotifications.add(
                                new Notification__c(
                                    Recipient__c = delContact.Id,
                                    WhatId__c = task.Id,
                                    IsDelegate__c = true,
                                    Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                                    StartDate__c = task.Start_Date__c,
                                    RemindUsing__c = 'Email'
                                )
                            ); 
                            
                            lstNotification.put(task.Id,new Notification__c(
                            Recipient__c = delContact.Id,
                            WhatId__c = task.Id,
                            IsDelegate__c = true,
                            Notification_Type__c = 'Message_To_PT_Task_Instant_Del_Type',
                            StartDate__c = task.Start_Date__c,
                            RemindUsing__c = 'Email'
                            ));
                            contactIds.add(delContact.Id); 
                            taskDt.put(delContact.Id,task.Start_Date__c); 
                        }
                    }
                }
            }
        }
        
        if(contactIds!= null && !contactIds.isEmpty()){
            List<User> userList = new List<User>();
            List<Id> matchedDtCont = new List<Id>();
            List<Id> NotMatchedDtCont = new List<Id>();
            Map<Long, List<Notification__c>> lstOffstHrNotification = new Map<Long, List<Notification__c>>();
            userList = [select Id,Name,TimeZoneSidKey,ContactId from User where ContactId IN:contactIds];
            Map<Id,Long> contOffsethr = new Map<Id,Long>(); 
            for(User u:userList){
                if(u.TimeZoneSidKey != null){
                    datetime partDtTime = datetime.now();
                    string participantDate = partDtTime.format('yyyy-MM-dd', u.TimeZoneSidKey);
                    Date participantdt;
                    participantdt = Date.valueOf(participantDate);
                    TimeZone tz = TimeZone.getTimeZone(u.TimeZoneSidKey);
                    Integer offSet = tz.getOffSet(DateTime.now());
                    Long offsethr = offset / (60 * 60 * 1000);
                    Date taskdate = taskDt.get(u.ContactId);
                    if(taskdate == participantdt){
                        //system.debug('both dates are same, fire email');
                        matchedDtCont.add(u.ContactId);
                        //NotMatchedDtCont.add(u.ContactId);contOffsethr.put(u.ContactId,offsethr);
                    }else if(taskdate > participantdt){
                        //system.debug('participant dt not reached,pause email');
                        NotMatchedDtCont.add(u.ContactId);
                        contOffsethr.put(u.ContactId,offsethr);
                    }else{
                        matchedDtCont.add(u.ContactId);
                    }
               }else{
                    matchedDtCont.add(u.ContactId);
               } 
            }
            
             for(Notification__c notif: newdeDupeNotifications){
                Notification__c N = notif;
                if(matchedDtCont.Contains(N.Recipient__c)){
                    deDupeNotifications.add(
                            new Notification__c(
                                Recipient__c = N.Recipient__c,
                                WhatId__c = N.WhatId__c,
                                Notification_Type__c = N.Notification_Type__c,
                                StartDate__c = N.StartDate__c,
                                RemindUsing__c = N.RemindUsing__c,
                                IsDelegate__c = N.IsDelegate__c
                            )
                        );
                }else if(NotMatchedDtCont.Contains(N.Recipient__c)){
                     Notification__c nfs = new Notification__c(
                            Recipient__c = N.Recipient__c,
                            WhatId__c = N.WhatId__c,
                            Notification_Type__c = N.Notification_Type__c,
                            StartDate__c = N.StartDate__c,
                            RemindUsing__c = N.RemindUsing__c,
                            IsDelegate__c = N.IsDelegate__c
                           
                        ); 
                    if(lstOffstHrNotification.containsKey(contOffsethr.get(N.Recipient__c))) {
                        lstOffstHrNotification.get(contOffsethr.get(N.Recipient__c)).add(nfs);
                    } else {
                        lstOffstHrNotification.put(contOffsethr.get(N.Recipient__c), new List<Notification__c> { nfs });
                    }    
                }
            }
            
            if(!lstOffstHrNotification.isEmpty()){
                 for(Long key:lstOffstHrNotification.keyset()){
                     List<Notification__c> lstntf = new List<Notification__c>();
                     lstntf = lstOffstHrNotification.get(key);
                     
                     params.clear();
                     params.put('NotificationList', lstntf);
                     params.put('OffsetHr', key);
                     Flow.Interview.Create_Notification_based_on_User_Timezone yourFlow = new Flow.Interview.Create_Notification_based_on_User_Timezone(params);
                     yourFlow.start();
                     lstntf.clear();
                 }
            }
        }
        
        if (!deDupeNotifications.isEmpty())
        notifications.addAll(deDupeNotifications);
        if (!notifications.isEmpty())
            insert notifications;
    }

    public static void processDefaultFieldValues(List<Task> tasks) {
        processDefaultFieldValues(tasks, UserInfo.getLanguage());
    }

    public static void processDefaultFieldValues(List<Task> tasks, String language) {
        Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(tasks);
        Map<String, Set<Id>> idsByObjectType = new Map<String, Set<Id>>();
        Map<String, Set<String>> fieldsByObjectType = new Map<String, Set<String>>();
        for (Task task : tasks) {
            if (task.Task_Code__c == null)
                continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null)
                continue;
            if (card.Source_Object_Type__c == null)
                continue;

            if (task.WhatId == null && card.Parameters__c != null) {
                if (
                    task.Task_Code__c == TaskService.TASK_CODE_COMPLETE_SURVEY &&
                    task.Survey_Invitation__c != null
                ) {
                    task.WhatId = task.Survey_Invitation__c;
                } else {
                    task.WhatId.addError('What Id can not be null');
                    continue;
                }
            }

            if (String.isEmpty(card.Parameters__c))
                continue;
            Map<String, String> cardParametersMap = CatalogParametersHelper.getParamsMap(
                card.Parameters__c
            );

            Set<Id> objectIds = idsByObjectType.get(card.Source_Object_Type__c);
            if (objectIds == null)
                objectIds = new Set<Id>();
            objectIds.add(task.WhatId);
            idsByObjectType.put(card.Source_Object_Type__c, objectIds);

            Set<String> objectFields = fieldsByObjectType.get(card.Source_Object_Type__c);
            if (objectFields == null)
                objectFields = new Set<String>();
            objectFields.addAll(cardParametersMap.values());
            fieldsByObjectType.put(card.Source_Object_Type__c, objectFields);
        }

        Map<Id, SObject> objectsMap = new Map<Id, SObject>();
        for (String objectType : idsByObjectType.keySet()) {
            List<SObject> objectsList = new List<SObject>();
            objectsList = CatalogParametersHelper.queryObjects(
                objectType,
                fieldsByObjectType.get(objectType),
                idsByObjectType.get(objectType)
            );
            for (SObject sobj : objectsList)
                objectsMap.put(sobj.Id, sobj);
        }
        TranslateHelper.translate(objectsMap.values(), language);

        for (Task task : tasks) {
            Map<String, String> cardParametersValueMap = new Map<String, String>();
            if (String.isEmpty(task.Task_Code__c))
                continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null)
                continue;
            if (task.WhatId != null) {
                SObject whatObject = objectsMap.get(task.WhatId);
                if (whatObject != null) {
                    cardParametersValueMap = CatalogParametersHelper.getParamsValueMap(
                        whatObject,
                        card.Parameters__c
                    );
                }
            }
            /**PEH-8833 */
            if (
                card.Subject_Label__c == 'Task_Subject_Complete_Survey' &&
                task.Survey_Invitation__c != null &&
                surveyInvitationNewPPMap.get(task.Survey_Invitation__c)
            ) {
                card.Subject_Label__c = 'Task_Subject_Complete_Survey_PP';
            }
            task.Subject = CatalogParametersHelper.prepareLabel(
                card.Subject_Label__c,
                cardParametersValueMap
            );

            String description = CatalogParametersHelper.prepareLabel(
                card.Comments_Label__c,
                cardParametersValueMap
            );
            if (description != null)
                task.Description = description;

            task.Action_URL__c = CatalogParametersHelper.prepareMergeFields(
                card.Action_Link__c,
                cardParametersValueMap
            );
        }
    }

    public static Map<Id, Boolean> isSurveyTaskNewPP(Set<Id> surveyInvitationSet) {
        List<SurveyInvitation> surveyInvitationList = [
            SELECT Id, Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c
            FROM SurveyInvitation
            WHERE Id IN :surveyInvitationSet
        ];
        Map<Id, Boolean> surveyInvitationMap = new Map<Id, Boolean>();
        for (SurveyInvitation surveyInvitation : surveyInvitationList) {
            if (
                surveyInvitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                CommunityTemplateService.TEMPLATE_PP ||
                (surveyInvitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                'Janssen' &&
                surveyInvitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c == 'PP 2.0')
            ) {
                surveyInvitationMap.put(surveyInvitation.Id, true);
            } else {
                surveyInvitationMap.put(surveyInvitation.Id, false);
            }
        }
        return surveyInvitationMap;
    }

    @TestVisible
    private static Map<String, Task_Catalog__mdt> getCardsMap(List<Task> tasks) {
        Set<String> catalogCodes = new Set<String>();
        Set<Id> surveyInvitationSet = new Set<Id>();
        for (Task task : tasks) {
            if (task.Task_Code__c != null) {
                catalogCodes.add(task.Task_Code__c);
            }
            if (task.Survey_Invitation__c != null) {
                surveyInvitationSet.add(task.Survey_Invitation__c);
            }
        }
        if (surveyInvitationSet.size() > 0) {
            surveyInvitationNewPPMap = isSurveyTaskNewPP(surveyInvitationSet);
        }
        List<Task_Catalog__mdt> cards = [
            SELECT
                Id,
                DeveloperName,
                Subject_Label__c,
                Comments_Label__c,
                Source_Object_Type__c,
                Action_Link__c,
                Parameters__c,
                Immediate_Email_Template__c,
                Immediate_Notification_Type__c
            FROM Task_Catalog__mdt
            WHERE DeveloperName IN :catalogCodes
        ];
        Map<String, Task_Catalog__mdt> cardsMap = new Map<String, Task_Catalog__mdt>();
        for (Task_Catalog__mdt card : cards)
            cardsMap.put(card.DeveloperName, card);
        return cardsMap;
    }

    @TestVisible
    private static Map<String, Task_Catalog__mdt> getCardsMapForTestClass() {
        Map<String, Task_Catalog__mdt> cardsMap = new Map<String, Task_Catalog__mdt>();

        Task_Catalog__mdt taskCatalog = new Task_Catalog__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog)
        );
        fields.put(
            Task_Catalog__mdt.DeveloperName.getDescribe().getName(),
            'Complete_Baseline_Survey'
        );
        fields.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Complete_Baseline_Survey'
        );
        fields.put(Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(), '');
        fields.put(Task_Catalog__mdt.Action_Link__c.getDescribe().getName(), 'baseline-survey?');
        fields.put(Task_Catalog__mdt.Parameters__c.getDescribe().getName(), '');
        fields.put(
            Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(),
            'Patient_Complete_Baseline_Survey'
        );
        fields.put(Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(), '');
        taskCatalog = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog.DeveloperName, taskCatalog);

        Task_Catalog__mdt taskCatalog2 = new Task_Catalog__mdt();
        Map<String, Object> fields2 = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog2)
        );
        fields2.put(Task_Catalog__mdt.DeveloperName.getDescribe().getName(), 'Complete_Survey');
        fields2.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Complete_Survey'
        );
        fields2.put(
            Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(),
            'SurveyInvitation'
        );
        fields2.put(Task_Catalog__mdt.Action_Link__c.getDescribe().getName(), 'survey?inv=##invId');
        fields2.put(
            Task_Catalog__mdt.Parameters__c.getDescribe().getName(),
            'SurveyName = Survey__r.NameinvId= Id'
        );
        fields2.put(
            Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(),
            'Patient_Complete_Baseline_Survey'
        );
        fields2.put(
            Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(),
            'Message_to_PT_Complete_BL_Survey_Type'
        );
        taskCatalog2 = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields2),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog2.DeveloperName, taskCatalog2);

        Task_Catalog__mdt taskCatalog3 = new Task_Catalog__mdt();
        Map<String, Object> fields3 = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog3)
        );
        fields3.put(
            Task_Catalog__mdt.DeveloperName.getDescribe().getName(),
            'Complete_Your_Profile'
        );
        fields3.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Complete_Your_Profile'
        );
        fields3.put(
            Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(),
            'Participant__c'
        );
        fields3.put(Task_Catalog__mdt.Action_Link__c.getDescribe().getName(), 'account-settings');
        fields3.put(Task_Catalog__mdt.Parameters__c.getDescribe().getName(), '');
        fields3.put(Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(), '');
        fields3.put(Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(), '');
        taskCatalog3 = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields3),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog3.DeveloperName, taskCatalog3);

        Task_Catalog__mdt taskCatalog4 = new Task_Catalog__mdt();
        Map<String, Object> fields4 = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog4)
        );
        fields4.put(
            Task_Catalog__mdt.DeveloperName.getDescribe().getName(),
            'Update_Your_Phone_Number'
        );
        fields4.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Update_Your_Phone_Number'
        );
        fields4.put(
            Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(),
            'Participant__c'
        );
        fields4.put(Task_Catalog__mdt.Action_Link__c.getDescribe().getName(), 'account-settings');
        fields4.put(Task_Catalog__mdt.Parameters__c.getDescribe().getName(), '');
        fields4.put(
            Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(),
            'Email_To_PT_For_Invalid_Number'
        );
        fields4.put(
            Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(),
            'Message_To_PT_For_Invalid_Number'
        );
        taskCatalog4 = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields4),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog4.DeveloperName, taskCatalog4);

        Task_Catalog__mdt taskCatalog5 = new Task_Catalog__mdt();
        Map<String, Object> fields5 = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog5)
        );
        fields5.put(Task_Catalog__mdt.DeveloperName.getDescribe().getName(), 'Select_COI');
        fields5.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Select_COI'
        );
        fields5.put(
            Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(),
            'Participant_Enrollment__c'
        );
        fields5.put(
            Task_Catalog__mdt.Action_Link__c.getDescribe().getName(),
            'account-settings?changePref#autocomplete=true'
        );
        fields5.put(Task_Catalog__mdt.Parameters__c.getDescribe().getName(), '');
        fields5.put(Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(), '');
        fields5.put(Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(), '');
        taskCatalog5 = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields5),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog5.DeveloperName, taskCatalog5);

        Task_Catalog__mdt taskCatalog6 = new Task_Catalog__mdt();
        Map<String, Object> fields6 = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(taskCatalog6)
        );
        fields6.put(
            Task_Catalog__mdt.DeveloperName.getDescribe().getName(),
            'Complete_Baseline_Survey_Invalid'
        );
        fields6.put(
            Task_Catalog__mdt.Subject_Label__c.getDescribe().getName(),
            'Task_Subject_Complete_Baseline_Survey'
        );
        fields6.put(Task_Catalog__mdt.Source_Object_Type__c.getDescribe().getName(), '');
        fields6.put(Task_Catalog__mdt.Action_Link__c.getDescribe().getName(), 'baseline-survey?');
        fields6.put(
            Task_Catalog__mdt.Parameters__c.getDescribe().getName(),
            'SurveyName = Survey__r.NameinvId= Id'
        );
        fields6.put(
            Task_Catalog__mdt.Immediate_Email_Template__c.getDescribe().getName(),
            'Patient_Complete_Baseline_Survey'
        );
        fields6.put(Task_Catalog__mdt.Immediate_Notification_Type__c.getDescribe().getName(), '');
        taskCatalog6 = (Task_Catalog__mdt) JSON.deserialize(
            JSON.serialize(fields6),
            Task_Catalog__mdt.class
        );
        cardsMap.put(taskCatalog6.DeveloperName, taskCatalog6);

        return cardsMap;
    }
}