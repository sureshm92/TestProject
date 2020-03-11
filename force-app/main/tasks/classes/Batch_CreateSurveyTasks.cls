/**
 * Created by Igor Malyuta on 02.10.2019.
 */

public class Batch_CreateSurveyTasks implements Database.Batchable<InvitationsWrapper>, Database.Stateful {

    private Map<Id, String> invitationsVisible;
    private Map<Id, String> failedInvitation;

    private Id userId;
    private Integer taskCreated;
    private Integer launchCount;

    public Batch_CreateSurveyTasks(Map<Id, String> invitationsVisible, Id userId, Integer taskCreated, Integer launchCount) {
        this.invitationsVisible = invitationsVisible;
        this.failedInvitation = new Map<Id, String>();
        this.userId = userId;
        this.taskCreated = taskCreated;
        this.launchCount = launchCount;
    }

    public List<InvitationsWrapper> start(Database.BatchableContext param1) {
        List<InvitationsWrapper> invitationsWrappers = new List<Batch_CreateSurveyTasks.InvitationsWrapper>();
        for (Id invId : invitationsVisible.keySet()) {
            invitationsWrappers.add(new InvitationsWrapper(invId, invitationsVisible.get(invId)));
        }

        return invitationsWrappers;
    }

    public void execute(Database.BatchableContext param1, List<InvitationsWrapper> wrappers) {
        Map<Id, String> invVisible = new Map<Id, String>();
        for (InvitationsWrapper wrapper : wrappers) invVisible.put(wrapper.invitationId, wrapper.visibleMode);

        try {
            taskCreated += TaskService.getInstance().createSurveyTasks(invVisible);
        } catch (Exception e) {
            failedInvitation.putAll(invVisible);
        }
    }

    public void finish(Database.BatchableContext param1) {
        if (!failedInvitation.isEmpty() && launchCount < 3 && !Test.isRunningTest()) {
            Database.executeBatch(
                    new Batch_CreateSurveyTasks(failedInvitation, userId, taskCreated, ++launchCount), 30);
        } else {
            //Send email to Admin
            try {
                List<Id> failedContactIds;
                if (!failedInvitation.isEmpty()) failedContactIds = countFailedTask(failedInvitation);

                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                List<User> user = [SELECT Id, Email FROM User WHERE Id = :userId];
                emailMessage.setToAddresses(new List<String>{user.get(0).Email});
                emailMessage.setSubject('Batch Create Survey Task');

                String messageBody = 'Task(s) created = ' + taskCreated
                        + '. Task(s) failed = ' + (failedContactIds == null ? '0' : '' + (failedContactIds.size() + '\n'));
                if(failedContactIds != null) {
                    messageBody += 'Failed contact ids:\n';
                    for(Integer i = 0; i < failedContactIds.size(); i++) {
                        messageBody += failedContactIds.get(i) + ', ';
                        if(Math.mod(3, i) == 0) messageBody += '\n';
                    }

                    messageBody = messageBody.removeEnd(', ');
                }

                emailMessage.setPlainTextBody(messageBody);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static void launch(Map<Id, String> invitationsVisible) {
        Database.executeBatch(new Batch_CreateSurveyTasks(invitationsVisible, UserInfo.getUserId(), 0, 1), 30);
    }

    private List<Id> countFailedTask(Map<Id, String> invitationsVisible) {
        Map<Id, SurveyInvitation> surveyInvitation = new Map<Id, SurveyInvitation>([
                SELECT
                        Id,
                        Participant_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN:invitationsVisible.keySet()
        ]);
        Map<Id, List<Id>> delegatesByParticipant = new Map<Id, List<Id>>();
        for (SurveyInvitation inv : surveyInvitation.values()) {
            delegatesByParticipant.put(inv.Participant_Enrollment__r.Participant_Contact__c, new List<Id>());
        }

        List<Patient_Delegate__c> patientDelegates = [
                SELECT Id,
                        Contact__c,
                        Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN:delegatesByParticipant.keySet()
        ];
        for (Patient_Delegate__c pd : patientDelegates) {
            delegatesByParticipant.get(pd.Participant__r.Contact__c).add(pd.Contact__c);
        }

        List<Id> failedContactIds = new List<Id>();
        for(Id invId : invitationsVisible.keySet()) {
            String visible = invitationsVisible.get(invId);
            Id pcId = surveyInvitation.get(invId).Participant_Enrollment__r.Participant_Contact__c;
            switch on visible {
                when 'Patient only', 'Patient or any Delegate', 'Any Delegate' {
                    failedContactIds.add(pcId);
                }
                when 'Each Delegate' {
                    failedContactIds.addAll(delegatesByParticipant.get(pcId));
                }
                when 'Patient and each Delegate' {
                    failedContactIds.add(pcId);
                    failedContactIds.addAll(delegatesByParticipant.get(pcId));
                }
            }
        }

        return failedContactIds;
    }

    public class InvitationsWrapper {
        public Id invitationId;
        public String visibleMode;

        public InvitationsWrapper(Id invitationId, String visibleMode) {
            this.invitationId = invitationId;
            this.visibleMode = visibleMode;
        }
    }
}