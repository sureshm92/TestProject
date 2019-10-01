/**
 * Created by Igor Malyuta on 01.10.2019.
 */

public class Batch_CreateSurveyTasks implements Database.Batchable<InvitationsWrapper>, Database.Stateful {

    private Map<Id, String> invitationsVisible;

    public class InvitationsWrapper {
        public Id invitationId;
        public String visibleMode;

        public InvitationsWrapper(Id invitationId, String visibleMode) {
            this.invitationId = invitationId;
            this.visibleMode = visibleMode;
        }
    }

    public Batch_CreateSurveyTasks(Map<Id, String> invitationsVisible) {
        this.invitationsVisible = invitationsVisible;
    }

    public List<InvitationsWrapper> start(Database.BatchableContext param1) {
        List<InvitationsWrapper> invitationsWrappers = new List<Batch_CreateSurveyTasks.InvitationsWrapper>();
        for(Id invId : invitationsVisible.keySet()) {
            invitationsWrappers.add(new InvitationsWrapper(invId, invitationsVisible.get(invId)));
        }

        return invitationsWrappers;
    }

    public void execute(Database.BatchableContext param1, List<InvitationsWrapper> wrappers) {
        Map<Id, String> invVisible = new Map<Id, String>();
        for(InvitationsWrapper wrapper : wrappers) invVisible.put(wrapper.invitationId, wrapper.visibleMode);

        TaskService.getInstance().createSurveyTasks(invVisible);
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void launch(Map<Id, String> invitationsVisible) {
        Database.executeBatch(new Batch_CreateSurveyTasks(invitationsVisible), 30);
    }
}