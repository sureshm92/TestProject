/**
 * Created by AlexKetch && Alexy Fisher on 3/3/2019.
 */

public with sharing class TriggerHandlerExecutor {
    private static Map<System.Type, TriggerHandler> handlerPool;
    private static Set<System.Type> bypassHandlerTypes;
    private static Map<System.Type, Set<TriggerOperation>> bypassHandlerTypesByEvent;
    private static Boolean debugMode;

    static {
        setDebugMode(false);
        handlerPool = new Map<System.Type, TriggerHandler>();
        bypassHandlerTypes = new Set<System.Type>();
        bypassHandlerTypesByEvent = new Map<System.Type, Set<TriggerOperation>>();
        ClassFactory.setCacheable(false);
    }

    private TriggerHandlerExecutor() {

    }

    public static void execute(System.Type handlerType) {
        TriggerHandler handler = handlerPool.get(handlerType);
        if (handler == null) {
            handler = (TriggerHandler) handlerType.newInstance();
            handler.setHandlerType(handlerType);
            handlerPool.put(handlerType, handler);
        }
        if (bypassHandlerTypes.contains(handlerType)) {
            return;
        }

        contextExecuteHandler(handler, handlerType);
    }

    private static void contextExecuteHandler(TriggerHandler handler, System.Type handlerType) {
        if (!Trigger.isExecuting) {
            return;
        }
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_INSERT)) {
                    handler.beforeInsert(Trigger.new);
                }

            }
            if (Trigger.isUpdate) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_UPDATE)) {
                    handler.beforeUpdate(Trigger.new, Trigger.oldMap);
                }
            }
            if (Trigger.isDelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_DELETE)) {
                    handler.beforeDelete(Trigger.old);
                }
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_INSERT)) {
                    handler.afterInsert(Trigger.new);
                }
            }
            if (Trigger.isUpdate) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_UPDATE)) {
                    handler.afterUpdate(Trigger.new, Trigger.oldMap);
                }
            }
            if (Trigger.isDelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_DELETE)) {
                    handler.afterDelete(Trigger.old);
                }
            }
            if (Trigger.isUndelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_UNDELETE)) {
                    handler.afterUnDelete(Trigger.new);
                }
            }
        }
    }


    public static void bypassHandler(System.Type handlerType) {
        bypassHandlerTypes.add(handlerType);
    }
    public static void bypassHandler(System.Type handlerType, TriggerOperation event) {
        if (!bypassHandlerTypesByEvent.containsKey(handlerType)) {
            Set<TriggerOperation > eventSet = new Set<TriggerOperation>{
                    event
            };
            bypassHandlerTypesByEvent.put(handlerType, eventSet);
        } else {
            Set<TriggerOperation > eventSet = bypassHandlerTypesByEvent.get(handlerType);
            if (!eventSet.contains(event)) {
                eventSet.add(event);
            }
            bypassHandlerTypesByEvent.put(handlerType, eventSet);
        }


    }
    public static void setDebugMode(Boolean debugMode) {
        TriggerHandlerExecutor.debugMode = debugMode;
    }
    public static Boolean isDebugMode() {
        return TriggerHandlerExecutor.debugMode;
    }


    public static void clearbypass(System.Type handlerType) {
        bypassHandlerTypes.remove(handlerType);
    }
    public static void clearbypass(System.Type handlerType, TriggerOperation event) {
        bypassHandlerTypesByEvent.get(handlerType).remove(event);
    }
}