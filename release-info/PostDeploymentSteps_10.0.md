## 1. Add Batch_CreateRecurringAdminTask to the Batch Control Panel

Add Batch_CreateRecurringAdminTask to the Batch Control Panel :

1. Create Batch Create Recurring Admin Task--> Go to Setup --> Click on App launcher --> Click on Batch Control Panel-->Click on ‘Add new job’ at bottom right corner-->select Batch as ‘Batch_CreateRecurringAdminTask' and the Batch label will be ‘CreateRecurringAdminTask' -- > Interval mode as ‘Days’  Relaunch interval and scope size as ‘1’  Launch now should be uncheck only and then click on ‘Create new Batch Detail’.
2. Then find out the ‘CreateRecurringAdminTask´ in the Batch Control Panel list and set the next launch as next day early morning 12:01AM in GMT+0(means if the scheduling user's timezone is IST(GMT+5:30) then schedule at 5:31AM or if the scheduling user's timezone is GMT-4 then schedule at 8:01PM) and click on run symbol.

## 2. Remove task# from the list view

Go to setup > Go to 'Community Task' object > click on Search Layout > Edit the default layout >
Remove Task Number from the selected list > click save

## 3. Update the password for Mulesoft SMS API

Go to setup > Named Credentials > click on 'MulesoftSMS' > Edit > copy the password from sent mail > Save

## 4. Update the custom notification delivery settings

1. Go to setup > Notification Builder > Custom Notifications > Select "PP RH Puhs Notification" > Edit > From the Supported Channels > Deselect "Desktop" > Save
2. Go to setup > Notification Builder > Notification Delivery Settings > Select "PP RH Puhs Notification" > Edit > From the Supported Channels > Deselect "Desktop" > Save
