## Notification in Updates

##### Steps for creating custom metadata:

1. In Setup -> Custom Metadata Types -> Notification Type click **Manage Records**
2. Click **New**

#####How to create:

-   **Notification Type Name**: Update_to\_<Recepient>\_<Event>
    (Where you should put what kind of Recipient Type for this message
    PT - means Participant, HCP, PI or eRP) and shortly about the trigger event) and then word **Type** to indicate metadata type
-   **Parameters Provider**:
    Choose that one you need for external parameters
    in your message
-   **Description**: put here short description about logic of this message
-   **Recipient Type**: PI, HCP, Participant, External Email (if this message for external user outside of SalesForce system)

1. In Setup -> Custom Metadata Types -> Notification Target click **Manage Records**
2. Click **New**

#####How to create:

-   **Notification Target Name**: HCP_Patient_Accepted_Email
    (Where you should put what kind of Recipient Type for this message
    (PT - means Participant, HCP, PI or eRP) and shortly about topic) and then word **Update** to indicate type of message
-   **Target_User_Group\_\_c**: Add _Participant_

### Do not forget

After creation **move your type and target** from default metadata directory to main\community-pages-pp_2\updates\customMetadata

Write down in NotificationCatalog class your new Notification Type for using later in your code

```
static public String MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE = 'Message_to_PT_has_not_Logged_In_Type';
```

##

####Classes for sending notifications are meant to send notifications. Not to do anything else.

##

#####How to use it in your logic to send UI update

1. create Notification for each Contact you need

```
Notification__c notification = new Notification__c();
```

#####Where:

-   **Recipient\_\_c**: Id field on Contact
-   **WhatId\_\_c**: String field where you can put any SObject Id for addition parameters. For example Participant Enrollment Id or CTP Id
-   **Notification_Type\_\_c**: Notification Type that you created previously
-   **Target_Record_Ids\_\_c**: Add the source record Id which trigerred the notification. In case of grouped notifications like televisit and messages, keep appending the record Ids as comma separated value.

####Attention:

-   To send study level updates run **Batch_CreateSummaryNotifications** Frequency - 10 min
-   To send platform level updates run **Batch_InsertPlatformResNotification** Frequency - 9 min
-   To remove expired/deleted resources run **Batch_RemoveExpiredResourceNotifications** Frequency - Once a day/ Adhoc when a resource is deleted
