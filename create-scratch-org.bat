@echo off
set startTime=%Time%
echo Creating scratch org...
call sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a %1

echo Creating OrgWideEmailSddresses...
call sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json

echo Pushing project in progress...
call sfdx force:org:open -p /lightning/setup/DeployStatus/home
call sfdx force:source:push -f

if %ERRORLEVEL% == 0 (
    echo Post setup in progress...
    call sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateUserRole.apex

    call sfdx force:data:tree:import -p data/import-plan.json

    call sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateSSAndHCPEStatuses.apex

    call sfdx force:user:permset:assign --permsetname PP_Approved_Languages_Edit
    call sfdx force:user:permset:assign --permsetname PP_Batch_Control_Panel
    call sfdx force:user:permset:assign --permsetname PP_CTP_Edit
    call sfdx force:user:permset:assign --permsetname PP_Email_Test_Board
    call sfdx force:user:permset:assign --permsetname PP_Manual_Creation_Panel
    call sfdx force:user:permset:assign --permsetname PP_Message_Configuration_Edit
    call sfdx force:user:permset:assign --permsetname PP_Motivational_Messages_Edit
    call sfdx force:user:permset:assign --permsetname PP_Participant_BL
    call sfdx force:user:permset:assign --permsetname PP_Participant_Non_PIII_View
    call sfdx force:user:permset:assign --permsetname PP_Participant_PII_Edit
    call sfdx force:user:permset:assign --permsetname PP_Participant_PII_On_Cases_View
    call sfdx force:user:permset:assign --permsetname PP_Payment_Vendors_Edit
    call sfdx force:user:permset:assign --permsetname PP_StudySite_Edit
    call sfdx force:user:permset:assign --permsetname PP_Study_Resources_Edit
    call sfdx force:user:permset:assign --permsetname PP_Toggle_Feature_Delta_Edit
    call sfdx force:user:permset:assign --permsetname PP_Travel_Vendors_Edit
    call sfdx force:user:permset:assign --permsetname PP_Trial_Surveys_Edit
    call sfdx force:user:permset:assign --permsetname PP_Visits_Configuration_Edit
    call sfdx force:user:permset:assign --permsetname PP_Visits_Results_Sharing_Edit
    call sfdx force:user:permset:assign --permsetname Patient_Portal_Edit_Study_Settings
    call sfdx force:user:permset:assign --permsetname SurveyCreator

    echo Push completed successfully! %startTime% - %Time%
) else (echo Push not completed properly, check logs and try again)
