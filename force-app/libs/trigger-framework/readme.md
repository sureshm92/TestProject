## Trigger framework

###### 1) Create  handler with name `<objectName>`Handler
e.g.
```sh
public with sharing class TherapeuticAreaPatientTriggerHandler  extends TriggerHandler {
}
```

###### 2) owerride   event that you need to handle 
e.g.
```sh
public with sharing class TherapeuticAreaPatientTriggerHandler  extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {
        TherapeuticAreaService.validationOnDuplicate(newList);
    }
}
```
###### 3)create/or use existing one service with name  `<objectName>`Service and method  that handle your business logic: 
e.g.
```sh
public override void beforeInsert(List<SObject> newList) {
        TherapeuticAreaService.validationOnDuplicate(newList);
        //TherapeuticAreaService.anotherMethod1(newList);
        //TherapeuticAreaService.anotherMethod2(newList);
    }
```
-   trigger example :
```sh
trigger TherapeuticAreaPatientTrigger on Therapeutic_Area_Patient__c (before insert, before update, after insert, after update) {
    TriggerHandlerExecutor.execute(TherapeuticAreaPatientTriggerHandler.class);
}
```

#### Considerations
- one trigger per Object
- name should be `<objctName>`Trigger
- declaration of the trigger should contains `all events before insert, before update, before delete, after insert, after update, after delete`
```sh
sfdx force:source:push
```
#### examples of usage
e.g.1
```java
Account acc = new Account(Name = 'test');
//prevent running 'after ins' operation again of this triggerhandler  if execution context contains account insert operation
TriggerHandlerExecutor.bypassHandler(AccountTriggerHandler.class, TriggerOperation.AFTER_INSERT);
insert acc;
TriggerHandlerExecutor.clearbypass(AccountTriggerHandler.class)
```
e.g.2
```java
Account acc = new Account(Name = 'test');
//bypass all events
TriggerHandlerExecutor.bypassHandler(AccountTriggerHandler.class);
insert acc;
TriggerHandlerExecutor.clearbypass(AccountTriggerHandler.class);
```
e.g.3 `debug mode `:
```java
 TriggerHandlerExecutor.setDebugMode(true);
Account acc = new Account(Name = 'test');
insert acc;
```
res 
```java
Stats for AccountTriggerHandler:BEFORE_INSERT
13:41:22.2 (408183792)|USER_DEBUG|[198]|DEBUG|Queries used 2
13:41:22.2 (408254162)|USER_DEBUG|[198]|DEBUG|Query rows used 2
13:41:22.2 (408320837)|USER_DEBUG|[198]|DEBUG|Dml statements used 0
13:41:22.2 (408382123)|USER_DEBUG|[198]|DEBUG|Dml rows used 1
```
