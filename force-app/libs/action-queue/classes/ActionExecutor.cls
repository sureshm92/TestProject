/**
 * Created by Nargiz Mamedova on 12/3/2019.
 */

public with sharing class ActionExecutor {

    public static String ACTION_STATUS_PENDING = 'Pending';
    public static String ACTION_STATUS_COMPLETED = 'Completed';
    public static String ACTION_STATUS_FAILED = 'Failed';
    public static String ACTION_STATUS_SCHEDULED = 'Scheduled';
    
    private static Map<String, Action_Execution_Setting__c> actionSettingsMap = new Map<String, Action_Execution_Setting__c>();
    private static Action_Execution_Setting__c orgDefaultSetting = new Action_Execution_Setting__c(
            Relaunch_Interval__c = 5,
            Repetitions_Count__c = 3,
            Remove_After_Complete__c = true
    );

    static {
        List<Action_Execution_Setting__c> actionExecutionSettings = [
                SELECT Id, Type__c, Relaunch_Interval__c, Repetitions_Count__c, Remove_After_Complete__c
                FROM Action_Execution_Setting__c
        ];
        for(Action_Execution_Setting__c act : actionExecutionSettings) {
            if(act.Type__c == null){
                orgDefaultSetting = act;
            } else {
                actionSettingsMap.put(act.Type__c + '', act);
            }
        }
    }

    private static Action_Execution_Setting__c getSetting(String actionType){
        Action_Execution_Setting__c actionSetting = actionSettingsMap.get(actionType);
        if(actionSetting == null) actionSetting = orgDefaultSetting;
        return actionSetting;
    }

    public static void execute(Action action){
        Action__c act = new Action__c(
                Type__c = action.getType().toString(),
                Body__c = JSON.serialize(action)
        );
        Execution_History__c history = new Execution_History__c();
        Action_Execution_Setting__c actionSetting = getSetting(act.Type__c);
        try {
            action.execute();
            act.Status__c = ACTION_STATUS_COMPLETED;
            history.Is_Success__c = true;
        } catch (Exception e) {
            act.Status__c = ACTION_STATUS_PENDING;
            Datetime nextExecutionDatetime = Datetime.now().addMinutes(actionSetting.Relaunch_Interval__c.intValue());
            act.Execution_Time__c = nextExecutionDatetime;
            history.Error_Message__c = e.getMessage();
            history.Stack_Trace__c = e.getStackTraceString();
            history.Is_Success__c = false;
        } finally {
            if(!actionSetting.Remove_After_Complete__c || act.Status__c != ACTION_STATUS_COMPLETED) {
                DMLService.insertRecord(act);
                DMLService.setLookup(history, 'Action__c', act);
                DMLService.insertRecord(history);
            }
        }
    }

    public static void execute(Action__c act){
        Execution_History__c history = new Execution_History__c();
        Action_Execution_Setting__c actionSetting = getSetting(act.Type__c);
        try{
            Type actionType = Type.forName(act.Type__c);
            Action action = (Action) JSON.deserialize(act.Body__c, actionType);
            action.execute();
            act.Status__c = ACTION_STATUS_COMPLETED;
            history.Is_Success__c = true;
        } catch (Exception e) {
            Datetime nextExecutionDatetime = Datetime.now().addMinutes(actionSetting.Relaunch_Interval__c.intValue());
            history.Error_Message__c = e.getMessage();
            history.Stack_Trace__c = e.getStackTraceString();
            history.Is_Success__c = false;
            if(act.Execution_Histories__r.size() < actionSetting.Repetitions_Count__c - 1) {
                act.Status__c = ACTION_STATUS_PENDING;
                act.Execution_Time__c = nextExecutionDatetime;
            } else {
                act.Status__c = ACTION_STATUS_FAILED;
                act.Execution_Time__c = null;
            }
        } finally {
            if(!actionSetting.Remove_After_Complete__c || act.Status__c != ACTION_STATUS_COMPLETED) {
                DMLService.updateRecord(act);
                DMLService.setLookup(history, 'Action__c', act);
                DMLService.insertRecord(history);
            } else {
                DMLService.deleteRecord(act);
            }
        }
    }

    public static void executeAsync(Action action, Datetime executeTime){
        Action__c act = new Action__c(
                Type__c = action.getType().toString(),
                Body__c = JSON.serialize(action),
                Execution_Time__c = executeTime,
                Status__c = ACTION_STATUS_PENDING
        );
        DMLService.insertRecord(act);
    }

     public static void executeAsync(Action action){
        executeAsyncImpl(JSON.serialize(action), action.getType().toString());
    }

     public static void executeAsync(Action__c act){
        executeAsyncImpl(JSON.serialize(act));
    }

    @Future(Callout=true)
    private static void executeAsyncImpl(String actionJSON, String actionTypeStr){
        Type actionType = Type.forName(actionTypeStr);
        Action action = (Action) JSON.deserialize(actionJSON, actionType);
        execute(action);
    }

    @Future(Callout=true)
    private static void executeAsyncImpl(String actionJSON){
        execute((Action__c) JSON.deserialize(actionJSON, Action__c.class));
    }
}