## Messaging framework

##### Manual for creating message:

1) In Setup -> Custom Metadata Types -> Notification Type click **Manage Records**
2) Click **New**

#####How to create: 

- **Notification Type Name**: Message_to_HCP_Patient_Accepted_Type
(Where you should put what kind of Recipient Type for this message 
(PT - means Participant, HCP, PI or eRP) and shortly about topic) and then word **Type** to indicate metadata type
- **Parameters Provider**:
Choose that one you need for external parameters 
in your message
- **Description**: put here short description about logic of this message
- **Recipient Type**: PI, HCP, Participant, External Email (if this message for external user outside of SalesForce system)

1) In Setup -> Custom Metadata Types -> Notification Target click **Manage Records**
2) Click **New**

#####How to create: 

- **Notification Target Name**: HCP_Patient_Accepted_Email
(Where you should put what kind of Recipient Type for this message 
(PT - means Participant, HCP, PI or eRP) and shortly about topic) and then word **Email, SMS or Push** to indicate type of message
- **Notification Type**:
Choose that one you created previously to link them
- **Message Body**: (only for SMS target type)
- **Email Template**: RP2_Patient_Accepted 
(template name in the system)
- **Email Template Delegate**: (if template for delegate has differences)  
- **Org Wide Email Address**: (for email only) 

for **HCP** Recipient Type use this:
```
IQVIA Referral Hub
```
for **Participant, PI** Recipient Type use this:
```
IQVIA Patient Portal
```

### Do not forget
After creation **move your type and target** from default metadata directory to messaging/customMetadata

Write down in NotificationType class your new Notification Type for using later in your code
```
static public String MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE = 'Message_to_PT_has_not_Logged_In_Type';
```
##
####Classes for sending notifications are meant to send notifications. Not to do anything else.
##

#####How to use it in your logic to send email

1) create Notification for each Contact you need
```
Notification__c notification = new Notification__c();
```
#####Where: 

- **Recipient__c**: Id field on Contact
- **WhatId__c**: String field where you can put any SObject Id for addition parameters. For example Participant Enrollment Id.
- **Notification_Type__c**: Notification Type that you created previously
- **Status__c**: Picklist field where value **Created** means that logic sends notification immediately. 
**Pending** status means that logic will send notification later. (for example in Batch logic) **Processing** status overrides Pending 
status when notification is sent successfully.

####Attention: 
- To send Email and SMS run Batch_ProcessNotification.